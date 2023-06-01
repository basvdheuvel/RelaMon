#!/bin/bash

source ~/.bashrc

if [ -z ${1+x} ]; then
    /bin/bash
else
    dir=${1}
    part=${2}
    mode=${3}
    if [ "$mode" == "impl" ]; then
        node implementations/$dir/$part.js
    elif [ "$mode" == "mon" ]; then
        PROTOCOL_PATH="./implementations/$dir/$part.json" node monitor.js
    else
        echo "Unknown mode \"$mode\""
    fi
fi
