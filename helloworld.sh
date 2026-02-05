#!/bin/bash
id=$(id -u)

if [ $id -ne 0 ]; then
    echo "Try with root user"
    exit 1
fi

ANSWER() {
    if [ $1 -ne 0 ]; then
        echo "$2 .... FAILED"
        exit 1
    else
        echo "$2 .... SUCCESS"
    fi
}

dnf install nginx -y
ANSWER $? "Installing nginx"
