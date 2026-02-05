#!/bin/bash
USERID=$(id -u)
FOLDER="/var/log/shell-roboshop"
FILE="$FOLDER/$0.log"
if [ $USERID -ne 0]; then 
    echo -e "Run with root user"
    exit 1
fi

mkdir -p $FOLDER

VALIDATE(){
    if [ $1 -ne 0]; then
     echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}


cp mongo.rep /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$FILE
VALIDATE $? "Installing Mongodb server"

systemctl enable mongod &>>$FILE
VALIDATE $? "Enable Mongodb"

systemctl start mongod
VALIDATE $? "Start Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"
