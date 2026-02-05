#!/bin/bash
id=$(id -u)
FOLDER="/var/log/shell_script"
FILE="/var/log/shell_script/$0.log"

if [ $id -ne 0 ]; then
    echo "Try with root user"
    exit 1
fi
mkdir -p $FOLDER


ANSWER() {
    if [ $1 -ne 0 ]; then
        echo "$2 .... FAILED"
        exit 1
    else
        echo "$2 .... SUCCESS"
    fi
}

dnf install nginx -y &>> $FILE
ANSWER $? "Installing nginx"
