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
        echo "$2 .... FAILED" | tee -a $FILE
        exit 1
    else
        echo "$2 .... SUCCESS" | tee -a $FILE
    fi
}
for package in $@
do
   dnf list installed $package  &>>$FILE
   if [ $? -ne 0]; then
           echo "$package not installed, installing now:"
           dnf install $package -y &>>$FILE
           ANSWER $? "Installing $package"
   else 
           echo "$package already installed"
   fi
done
