#!/bin/false "This script should be sourced in a shell, not executed directly"

if [[ "$SHELL" == "/bin/bash" ]]; then
    # export DP_ROOT=$(dirname ${BASH_SOURCE})
    # 绝对路径
    export SMART_ROOT=$(cd $(dirname "${BASH_SOURCE}");pwd)
    if ! grep -q "source ${SMART_ROOT}/dprc.sh" ~/.bashrc; then
        echo "source ${SMART_ROOT}/dprc.sh" >> ~/.bashrc
        echo "" >> ~/.bashrc
    fi
    if ! grep -q "source ${SMART_ROOT}/dprc.sh" ~/.bash_profile; then
        echo "source ${SMART_ROOT}/dprc.sh" >> ~/.bash_profile
        echo "" >> ~/.bash_profile
    fi
elif [[ "$SHELL" == "/bin/zsh" ]]; then
    # https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
    # 绝对路径
    export SMART_ROOT=$(cd $(dirname ${(%):-%N});pwd)
    if ! grep -q "source ${SMART_ROOT}/dprc.sh" ~/.zshrc; then
        echo "source ${SMART_ROOT}/dprc.sh" >> ~/.zshrc
        echo "" >> ~/.zshrc
    fi
else
    echo "unsupported shell: $SHELL"
fi

function stinit() {
    ${SMART_ROOT}/script/init.sh "$@"
}

function stbuild () {
    ${SMART_ROOT}/script/build.sh "$@"
}





