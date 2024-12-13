#!/usr/bin/env bash

sudo sslocal -c ~/shadowsocks.json -d start
if  [ -z "`sudo lsof -i:1080`" ]; then
    echo ss failed
    exit
fi

sudo systemctl restart privoxy
if  [ -z "`sudo lsof -i:8118`" ]; then
    echo privoxy failed
    exit
fi

echo shadowsocks launched
