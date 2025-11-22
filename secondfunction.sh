#!/bin/bash 


showname() {
    echo "Hello $1"
    [ "${1,,}" = "adekunle" ] && return 0 || return 1
}

showname "$1"
if [ $? -eq 1 ]; then
    echo "Someone unknown login to the server"
fi

