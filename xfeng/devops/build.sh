#!/bin/bash
script_dir=$(dirname "$0")
DEVOPS_DIR=$(cd "${script_dir}"; pwd)
ROOT_DIR=$(cd "${DEVOPS_DIR}"/..; pwd)
targets=("xfeng")

BIN_DIR=${ROOT_DIR}/bin
#创建编译目录
if [ ! -d "$BIN_DIR" ]; then
    mkdir "${BIN_DIR}" 
fi
for target in ${targets}; do
    build_option=""
    outfile_name=${target}

    cd "${ROOT_DIR}/app/${target}"
    if ! go build ${build_option} -o "${BIN_DIR}/${outfile_name}"; then
        exit 1
    fi
    if [ -d "devops" ]; then
        cp -r devops/* "${BIN_DIR}/${target}/"
    fi
done