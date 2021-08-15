---
title: php源码分析(2)-编译&执行
date: 2015-11-26
tags:
- php
- php源码
---
### 前言 ###
上一篇中将php核心内容归结为三件事情：

1. 编译：将php源码编译为opcode（zend\_op\_array)
2. 执行：将上述opcode序列按顺序执行
3. 执行上述两项功能所需要的基础环境(对外接口，基本数据结构，内存管理，线程安全...)

今天分享下前面两项是如何进行的——**编译和执行**

### 从哪里开始编译和执行的 ###

先看如下一段代码,定义在`/Zend/zend.c:1309`行（PHP5.6）
```c
	ZEND_API int zend_execute_scripts(int type TSRMLS_DC, zval **retval, int file_count, ...) /* {{{ */
	{
    	va_list files;
    	int i;
    	zend_file_handle *file_handle;
		......
        EG(active_op_array) = zend_compile_file(file_handle, type TSRMLS_CC);
        if (file_handle->opened_path) {
            int dummy = 1;
            zend_hash_add(&EG(included_files), file_handle->opened_path, strlen(file_handle->opened_path) + 1, (void *)&dummy, sizeof(int), NULL);
        }
        zend_destroy_file_handle(file_handle TSRMLS_CC);
        if (EG(active_op_array)) {
            EG(return_value_ptr_ptr) = retval ? retval : NULL;
            zend_execute(EG(active_op_array) TSRMLS_CC);
            zend_exception_restore(TSRMLS_C);
			......
		}
		......
	}
```
基本上php源码文件都是通过调用这个函数来完成解析(编译)和执行的，函数做了三件事情：

1. 调用**`zend_compile_file`**函数将要执行的php文件编译成为op_array结构，并将其设置全局active\_op\_array
2. 调用**`zend_execute`**函数执行上面编译出来的zend\_op_array
3. 如果存在异常，尝试从异常中恢复

不知不觉中，我们今天两大主角华丽丽的登场了——**`zend_compile_file`**(编译)和**`zend_execute`**（执行）

### 从编译开始 ###

zend\_compile_file定义如下：

	ZEND_API zend_op_array *(*zend_compile_file)(zend_file_handle *file_handle, int type TSRMLS_DC);
这是一个函数指针，具体实现函数实现在zend引擎初始化（`/Zend/zend.c:683`）时赋值的，这样做的好处是不言自明的（想想apc的实现）
```c
	#if HAVE_DTRACE
	/* build with dtrace support */
		zend_compile_file = dtrace_compile_file;
		zend_execute_ex = dtrace_execute_ex;
		zend_execute_internal = dtrace_execute_internal;
	#else
		zend_compile_file = compile_file;
		zend_execute_ex = execute_ex;
		zend_execute_internal = NULL;
```
闲话少说，让我们来目光转移到编译真正的主角上`compile_file`(/Zend/zend_language_scanner.c:555),代码就不贴了。
