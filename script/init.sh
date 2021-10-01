#!/bin/bash

GO_VERSION=1.13.5
function main() {
    while getopts 'h' OPT; do
        case $OPT in
            *)
                usage
                exit 0
                ;;
        esac
    done


    # 没有go的话，下载go
    if ! which go > /dev/null 2>&1; then
        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            curl -O https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            wget https://dl.google.com/go/go${GO_VERSION}.darwin-amd64.tar.gz
            sudo tar -C /usr/local -xzf go${GO_VERSION}.darwin-amd64.tar.gz
        else
            echo "unsupported ostype: $OSTYPE"
            exit 1
        fi
    fi
}

function usage() {
    cat << EOF
dpinit
    initiate environment

usage: dpinit
EOF
}

main "$@"
