---
title: php taint扩展分析
date: 2016-01-04
tags:
- taint
- php扩展

---
### 背景介绍 ###
**[php taint](http://www.laruence.com/2012/02/14/2544.html)**是大神Laruence开发的一款侦测php安全漏洞的扩展程序，往下看之前请自行先了解下。

最近在公司部署到开发环境，发现taint没有正确甄别出存在漏洞的代码，只好自己分析修改了。废话少述，挽起袖子...开撸!

---

### 一、taint做了什么 ###
taint扩展的原理其实并不复杂，四句话就可以讲清楚：

>1. 所有由用户提交的数据都是‘不安全’的
>2. 所有由上述不安全数据经过计算产生的数据都**可能**是‘不安全’的(这大概也是taint名称的由来吧)
>3. 对上述数据进行过滤，转义操作可以让数据转化为安全数据
>4. **直接(不处理)**使用不安全的数据进行输出，数据库操作，目录遍历，shell命令...都是被不允许的

**$_GET,$_POST,$_COOKIE数组内所有数据都被添加了特定标记**
```php
    $a = $_GET['a'];
    $b = $_POST['b'];
    $c = $_COOKIE['c'];
```
**标记过的数据经过特定运算产生的数据同样添加了特定标记**
```php
    $d = $a.'dd';
    $e = strval($a);//去字符串值，标准库函数
    $f = explode($a); //返回值$e数组中每个成员都被标记
    $g = implode($a); //如果$_GET['a']是个数组，输出的$f变量就可能包含危险字符
```

**标记过的数据进行了过滤、转义等操作可以移除该标记**
  ```php
    $d = addslash($d);
    $f = htmlspecialchars($d);
  ```

**标记过的数据用于输出，数据库，文件系统，shell操作会触发一个严重错误!**

    Warning: main() [function.echo]:Attempt to echo a string that might be tainted in %s.php on line %d

详见laruence另外一篇文章[Taint-0.3.0(A XSS codes sniffer) released](http://www.laruence.com/2012/02/18/2560.html)

---

### 二、如何给数据添加标记 ###

为了讲清楚这个问题，需要先了解下php内核空间是如何存储变量的。

写过php的人都知道，php是弱类型的语言，基本类型之间可以自动转换，但是php依然是有类型的，翻阅下php手册就会发现php有8种数据类型:
>__四种基本类型__ (bool，int，float[double]，string)

>__两种复合类型__ (array，object)

>__两种特殊类型__ (resource,NULL)

而上述类型在php内核(c语言)中全是一种类型--__zval__
```c
	typedef struct _zval_struct zval;

	struct _zval_struct {
    	zvalue_value value;		//变量值
    	zend_uchar type;		//变量类型(bool,int,float,string,array,object,resource,null)
    	zend_uint refcount__gc;	//引用计数
    	zend_uchar is_ref__gc;	//是否是引用类型
	};

	typedef union _zvalue_value {
    	long lval;				//int,bool,resource 值
    	double dval;			//float 值
    	struct {				//string 值
        	char *val;
        	int len;
    	} str;
    	HashTable *ht;			//array 值
    	zend_object_value obj;	//object值
	} zvalue_value;
```
这里我们只关注string类型(为什么自己思考下)，string结构体中包含两个字段：一个char型指针和一个整型数，前者表示字符串首地址，后者表示字符串实际长度。

回想下在C语言中仅用一个char型指针来表示字符串，结尾以一个字节的 **\0** 来表示,这里并不探讨php内核为什么要如此表达字符串，但是这种方式却给了taint扩展标记字符串而不影响其他功能的方法。正因为上述方式，php内核中的字符串在进行各种处理时不依赖于字符串结尾的**\0**(尽管该\0依然存在)，taint扩展得以在需要标记的字符串后边添加了4个额外的字节，并在其中写如了一个特定的魔数__0x6A8FCE84__。

	index.php?a=dangers;
	$a = $_GET['a'];

上述字符串$a在经过标记后在内核中表示如下
```c
	str.val = 0x64616E67 0x65727300 0x6A8FCE84	//演示，大端系统和小端系统是不同的
	str.len = 7;
```
注意到魔数出现在0x657273__00__(__\0__)后面并且**长度len**依然正确存储着字符串的实际长度，标记操作不对正常功能产生任何影响

---

### 三、给‘污染’的数据添加标记 ###


php内核中字符串的拷贝是用下面的函数完成的，传入源字符串指针及长度，返回一个新的字符串指针，这也证明了在字符串后面加上4个字节的魔数不影响该字符串的操作。

	//Zend/zend_variables.c:123
	zvalue->value.str.val = (char *) estrndup_rel(zvalue->value.str.val, zvalue->value.str.len);


现在考虑如下代码:
```php
	$a = $_GET['a'];				//$_GET['a']是标记数据，假如$_GET['a'] = 'dangers';
	$a1 = $a;						//赋值操作
	$b = $a.'dd';					//字符串连接
	$c = substr($a, 0, strlen($a));	//函数加工
```
- 如上文所述，从$a拷贝7个字节长度的字符串到$a1过程中，并不会拷贝最后4个字节的魔数，标记丢失了,同理，$b的标记也丢失了。
- 函数substr取变量$a的指定部分拷贝到一个全新的变量并返回，很容易想到这个返回值可能包含了$a中的恶意数据，但却没有正确的标记出来

显然，为了解决上面两个问题，我们需要在这些字符串操作过程中加如一些自己的逻辑从而将运算结果也标记为不安全。上述操作大概可以分为两类:
赋值，连接...(zend虚拟机的opcode操作)、substr，trim，strstr等标准库函数。

opcode这不再展开了(呵呵，我也没没十分弄清楚)，记住一点：opcode就是实体机中的cpu指令，每个php opcode在内核中都对应着一个C函数称为opcode_handler_t，并且zend虚拟机向外暴露了一个api用来注册自己的处理函数，如下：

	zend_set_user_opcode_handler（zend_uchar opcode, user_opcode_handler_t handler）

taint正式利用这个api，重写了几个关键的opcode(ZEND_CONCAT,ZEND_ASSIGN_CONCAT,ZEND_ASSIGN,ZEND_ASSIGN_REF...)。

至于标准库函数(包括其他扩展暴露到用户空间的函数)就更容易了，php内核中在内存中有一张函数表，这是一张hash表，taint扩展在初始化阶段替换了函数表中对应函数的指针，从而插入了自己的逻辑，这里我贴出substr函数的源码:
```c
	/* {{{ proto string substr(string $string, int $start[, int $length])
	 */
	PHP_FUNCTION(taint_substr)
	{
		zval *str;
		long start, length;
    	int	tainted = 0;
		//解析参数
		if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "zl|l", &str, &start, &length) == FAILURE) {
			return;
		}
		//判断参数是否是一个被标记的字符串
		if (IS_STRING == Z_TYPE_P(str) && PHP_TAINT_POSSIBLE(str)) {
			tainted = 1;
		}
		//调用原函数
		TAINT_O_FUNC(substr)(INTERNAL_FUNCTION_PARAM_PASSTHRU);
		//根据taint字段值标记返回值
		if (tainted && IS_STRING == Z_TYPE_P(return_value) && Z_STRLEN_P(return_value)) {
			Z_STRVAL_P(return_value) = erealloc(Z_STRVAL_P(return_value), Z_STRLEN_P(return_value) + 1 + PHP_TAINT_MAGIC_LENGTH);
			PHP_TAINT_MARK(return_value, PHP_TAINT_MAGIC_POSSIBLE);
		}
	}
	/* }}} */
```
到这里基本上完成taint扩展的原理分析了，有兴趣的可以进一步了解下

---

### 错误警告 ###
同上文的原理，taint重写了部分输出语句的opcode(ZEND_ECHO,ZEND_PRINT...),部分标准库函数（fopen，mysql_query，PDO::query，exec...），当检测到参数是一个标记过的变量时触发一个错误！
### 为什么公司开发环境taint扩展不能用 ###

公司用了yii开发框架，了解了taint原理后，阅读yii模板渲染部分的实现时发现了如下代码:
```php
	public function renderInternal($_viewFile_,$_data_=null,$_return_=false)
	{
		// we use special variable names here to avoid conflict when extracting data
		if(is_array($_data_))
			extract($_data_,EXTR_PREFIX_SAME,'data');
		else
			$data=$_data_;
		...
	}
```
yii在渲染的调用了extract函数，这是php标准库的函数，作用是将数组中的所有成员导入到当前执行栈的符号表中，taint扩展并没有重写这个函数，导致在执行后所有标记都丢失了，考虑到该函数在mvc框架中使用频度，便修改了taint扩展，重写了extract函数(由于该函数并不返回字符串，而是直接导入到符号表中，与上面所述的函数大有差别，实现比较复杂，我的实现方法也很狗屎，这里就不细讲，期待Laruence大神给出一个官方方案),实际上还有urlencode，urldecode函数也需要重写。

---

### 后记 ###

taint侦测危险代码的错误原理**简单粗暴**(往往是最有效的)，会有漏网之鱼，也可能伤及无辜，但却能督促开发人员有一个好的编码习惯：不相信客户端的任何数据，时刻谨记数据净化的重要性!

taint扩展目前版本还未区分不同攻击类型，htmlspecialchars能够用来防范xss，但对数据库查询却不起作用，addslashs对针对shell，数据库的攻击会有作用，但是对xss却用处不大... 我的改进建议是充分的用好那4个字节的魔数，可以选用前3个字节作为一个特殊标识，充分利用后面1个字节来记录字符串依然对哪些攻击类型有风险（而不是一刀切的标记有或者无风险）。当对字符串调用了htmlspecialchars后仅仅将标识xss攻击的1一个数据位置为0，依此类推，只有当所有攻击类型都被标记为0后改字符串才是一个完全干净的数据
