#!/bin/bash
source_folder="/usr/local/src"
user="nouser"
group="nouser"
#初始化编译环境
echo "###初始化编译环境"
yum update
yum install gcc gcc-c++ autoconf automake

#进入脚本目录

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR


TMP_DIR=${SCRIPT_DIR}/.tmp
# 初始化tmp目录
if [ ! -d "${TMP_DIR}" ]; then
    mkdir "${TMP_DIR}"
fi
cd ${TMP_DIR}
tar -zxf ../soft/pcre-8.40.tar.gz
tar -zxf ../soft/openssl-1.0.2u.tar.gz
tar -zxf ../soft/zlib-1.2.11.tar.gz
tar -jxf ../soft/jemalloc-5.2.1.tar.bz2
tar -zxf ../soft/tengine-2.1.0.tar.gz
#安装pcre
if [ ! -d "/usr/local/pcre" ]; then
    echo "开始安装pcre"
    cd ${TMP_DIR}/pcre-8.40
    ./configure --prefix=/usr/local/pcre
    make && make install
fi
echo "prce已安装"

# openssl
if [ ! -d "/usr/local/openssl" ]; then
    echo "开始安装openssl"
    cd ${TMP_DIR}/openssl-1.0.2u
    ./config --prefix=/usr/local/openssl
    make && make install
fi
echo "openssl已安装"
# zlib
if [ ! -d "/usr/local/zlib" ]; then
    echo "开始安装zlib"
    cd ${TMP_DIR}/zlib-1.2.11
    ./configure --prefix=/usr/local/zlib
    make && make install
fi
echo "zlib已安装"

if [ ! -d "/usr/local/jemalloc" ]; then
    echo "开始安装jemalloc"
    cd ${TMP_DIR}/jemalloc-5.2.1
    ./configure --prefix=/usr/local/jemalloc
    make && make install
fi
echo "jemalloc已安装"

# 初始化用户
if ! id -u ${user} >/dev/null 2>&1; then
    groupadd ${group}
    useradd -s /sbin/nologin -g ${user} ${group}
fi

#安装tegine
if [ ! -d "/usr/local/nginx" ]; then
    cd ${TMP_DIR}/tengine-2.1.0
    ./configure --prefix=/usr/local/nginx \
        --user=${user} \
        --group=${group} \
        --with-pcre=${TMP_DIR}/pcre-8.40\
        --with-openssl=${TMP_DIR}/openssl-1.0.2u \
        --with-jemalloc=${TMP_DIR}/jemalloc-5.2.1 \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_stub_status_module \
        --with-http_concat_module \
        --with-zlib=${TMP_DIR}/zlib-1.2.11
    sed -i "3 s/-Werror//" objs/Makefile #解决告警
    sed -i "35 s/cd.current_salt/\/\/cd.current_salt/" src/os/unix/ngx_user.c #解决系统兼容问题
    make && make install
fi
echo "tengine 安装成功"

#添加系统启动
echo "设置开机启动"
if [ ! -f "/etc/init.d/nginx" ]; then
    cp ${SCRIPT_DIR}/tengine/init.sh /etc/init.d/nginx
    chmod a+x /etc/init.d/nginx
    chkconfig --add /etc/init.d/nginx
    chkconfig nginx on
fi

#清理
echo "执行清理"
if [ ! -z ${TMP_DIR} ] && [ -d ${TMP_DIR} ]; then
    rm -rf ${TMP_DIR}
fi
