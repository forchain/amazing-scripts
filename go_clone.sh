#!/usr/bin/env bash

url=${1#https://}

if [ -z $1 ]; then
    echo please specify repo address
    echo example: ./go_clone.sh https://github.com/forchain/some_repo
    exit
fi

path=~/${url}

if [ -d ${path} ]; then
    git -C ${path} pull
else
    git clone https://${url} ${path} --depth=1
fi

ln -s ${path} ${GOPATH}/src/${url}
