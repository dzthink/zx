#!/bin/bash
function main() {
    while getopts 'h' OPT; do
        case $OPT in
            *)
                usage
                exit 0
                ;;
        esac
    done
    build_xfeng
}

function usage() {
    cat << EOF
stbuild
    build all project

usage: stbuid [xfeng]
EOF
}

function build_xfeng() {
    "${SMART_ROOT}"/xfeng/devops/build.sh
}

main "$@"