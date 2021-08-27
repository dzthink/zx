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

#初始化源码目录
if [ ! -d "$source_folder" ]; then
    mkdir "$source_folder"
fi

#安装pcre
if [ ! -d "/usr/local/pcre" ]; then
    echo "开始安装pcre"
    cd ${source_folder}
    tar zxvf ../lib/pcre-8.40.tar.gz
    cd pcre-8.40
    ./configure --prefix=/usr/local/pcre
    make && make install
    cd .. && rm -rf pcre-8.40
fi
echo "prce已安装"

# openssl
if [ ! -d "/usr/local/openssl" ]; then
    echo "开始安装openssl"
    cd ${source_folder}
    tar zxvf ../lib/openssl-1.0.2.tar.gz
    cd openssl-1.0.2
    ./configure --prefix=/usr/local/openssl
    make && make install
    cd .. && rm -rf openssl-1.0.2
fi
echo "openssl已安装"
# zlib
if [ ! -d "/usr/local/zlib" ]; then
    echo "开始安装zlib"
    cd ${source_folder}
    tar zxvf ../lib/zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure --prefix=/usr/local/zlib
    make && make install
    cd .. && rm -rf zlib-1.2.11
fi
echo "zlib已安装"

if [ ! -d "/usr/local/jemalloc" ]; then
    echo "开始安装jemalloc"
    cd ${source_folder}
    tar jxvf ../lib/jemalloc-5.2.1.tar.bz2
    cd jemalloc-5.2.1
    ./configure --prefix=/usr/local/jemalloc
    make && make install
    cd .. && rm -rf jemalloc-5.2.1 
fi
echo "jemalloc已安装"

# 初始化用户
if ! id -u ${user} >/dev/null 2>&1; then
    groupadd ${group}
    useradd -s /sbin/nologin -g ${user} ${group}
fi

#安装tegine
if [ ! -d "/usr/local/nginx" ]; then
    cd ${source_folder}
    tar -zxvf tengine-2.1.0.tar.gz
    cd tengine-2.1.0
    ./configure --prefix=/usr/local/nginx \
        --user=${user} \
        --group=${group} \
        --with-pcre=/usr/local/src/pcre-8.36 \
        --with-openssl=/usr/local/src/openssl-1.0.2 \
        --with-jemalloc=/usr/local/src/jemalloc-3.6.0 \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_stub_status_module \
        --with-http_concat_module \
        --with-zlib=/usr/local/src/zlib-1.2.8
    make && make install
fi
