#!/bin/sh

function pyenv_main() {
    pyenv_path=$(command -v pyenv)
    echo $pyenv_path
    if -n "$pyenv_path"; then
        if [[ $pyenv_path == $INSTALL_PATH* ]]; then
            echo "pyenv was already installed, resintall[Y] or EXIT[N]":
            read input
            if [[ $input =~ ^[Yy]$ ]]; then
                uninstall_pyenv
                install_pyenv
            else 
                exit 0
            fi
        else
            echo "pyenv was already installed by others, just use it or uninstall it first"
            exit 1
        fi
    else
        install_pyenv
    fi
}

function uninstall_pynenv() {
    echo "uninstall"
}

function install_pyenv() {
    export PYENV_GIT_TAG=v2.4.0
    export PYENV_ROOT=${INSTALL_PATH}/.pyenv
    curl https://pyenv.run | bash
    add_to_rcfile "export PYENV_ROOT=$HOME/bin/.pyenv"
    add_to_rcfile '[[ -d $PYENV_ROOT/bin ]] && export PATH=$PYENV_ROOT/bin:$PATH'
    add_to_rcfile 'eval "$(pyenv init -)"'
}

function main() {
    while getopts 'h' OPT; do
        case $OPT in
            *)
                usage
                exit 0
                ;;
        esac
    done
    if [ "$#" -lt 1 ]; then
        echo "Please input the name of software you want to install"
        usage
        exit 1
    fi
    
    "${1}_main" "${@:2}"
}


function usage() {
    cat << EOF
install
    install softwares

usage: install {name} [args...] [-h]
    -h help tips

EOF
}

function add_path() {
    add_to_rcfile "export PATH=$PATH:$1"
}

function add_to_rcfile() {
  RCFILE=$HOME/.bash_profile
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        RCFILE="$HOME/.bash_profile"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        RCFILE="$HOME/.zshrc"
    else
        echo "unsupported ostype: $OSTYPE"
        exit 1
    fi
    if [ ! -e ${RCFILE} ]; then
        touch "${RCFILE}"
    fi
    if ! grep -q "$1" "$RCFILE"; then
        echo $1 >> $RCFILE
    fi
    source $RCFILE
}

INSTALL_PATH=${HOME}/bin
mkdir -p $INSTALL_PATH
add_path $INSTALL_PATH
echo "begin install"
main "$@"