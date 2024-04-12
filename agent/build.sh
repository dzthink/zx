#!/bin/bash

WORKDIR=$(cd $(dirname $0); pwd)
GOBIN=${WORKDIR}/bin/gobin

if ! [ -d ${GOBIN} ]; then
    mkdir ${GOBIN}
fi
mkdir -p ${HOME}/bin
RCFILE=$HOME/.bash_profile
GOODS="linux"
GOFILE="go1.22.2.linux-amd64.tar.gz"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    RCFILE="$HOME/.bash_profile"
    GOFILE="go1.22.2.linux-amd64.tar.gz"
    GOODS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    RCFILE="$HOME/.zshrc"
    GOFILE="go1.22.2.darwin-amd64.tar.gz"
    GOODS="darwin"
else
    echo "unsupported ostype: $OSTYPE"
    exit 1
fi

if [ ! -e ${RCFILE} ]; then
    touch "${RCFILE}"
fi

if ! grep -q "${HOME}/bin" "$RCFILE"; then
    echo "export PATH=$PATH:${HOME}/bin" >> $RCFILE
fi
source $RCFILE
TMPDIR=$(mktemp -d /tmp/tmpgo.XXXXXX)
# 避免包名冲突
cd ${TMPDIR}

# 没有go的话，下载go
if ! which go > /dev/null 2>&1; then
    curl -O https://dl.google.com/go/${GOFILE} 
    sudo tar -C /usr/local -xzf ${GOFILE}
    if ! grep -q "/usr/local/go/bin" "$RCFILE"; then
        echo "export PATH=$PATH:/usr/local/go/bin" >> $RCFILE
    fi
    source $RCFILE
fi
cd ${WORKDIR}
GOOS=${GOODS} GOARCH=amd64 go build -o ${GOBIN} ${WORKDIR}

cp -f ${GOBIN}/agent $HOME/bin/zx
chmod a+x $HOME/bin/zx