#!/bin/bash

USERID=$(id -u)
FOLDER="/var/log/shell-roboshop"
FILE="$FOLDER/mongodb.log"

R="\e[31m"
G="\e[32m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "${R}Run with root user${N}"
    exit 1
fi

mkdir -p $FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... ${R}FAILURE${N}" | tee -a $FILE
        exit 1
    else
        echo -e "$2 ... ${G}SUCCESS${N}" | tee -a $FILE
    fi
}

# Copy repo
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$FILE
VALIDATE $? "Copied Mongo repo"

# Install MongoDB
dnf install mongodb-org -y &>>$FILE
VALIDATE $? "Installing MongoDB server"

# Enable service
systemctl enable mongod &>>$FILE
VALIDATE $? "Enable MongoDB"

# Start service
systemctl start mongod &>>$FILE
VALIDATE $? "Start MongoDB"

# Allow remote connection
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$FILE
VALIDATE $? "Allow remote connections"

# Restart service
systemctl restart mongod &>>$FILE
VALIDATE $? "Restart MongoDB"
