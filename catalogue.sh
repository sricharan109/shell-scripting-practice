#!/bin/bash
USERID=$(id -u)
FOLDER="/var/log/shell-roboshop"
FILE="$FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.cerry.in
if [ $USERID -ne 0]; then 
    echo -e "Run with root user"
    exit 1
fi

mkdir -p $FOLDER

VALIDATE(){
    if [ $1 -ne 0]; then
     echo -e "$2 . FAILURE " | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 . SUCCESS " | tee -a $LOGS_FILE
    fi
}
mkdir -p $FOLDER

dnf module disable nodejs -y &>>$FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$FILE
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y &>>$FILE
VALIDATE $? "Install NodeJs"

id roboshop &>>$FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
     echo -e "Roboshop user already exist"
fi

mkdir -p /app
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$FILE
VALIDATE $? "Uzip catalogue code"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Downloading catalogue code"


systemctl daemon-reload
systemctl enable catalogue  &>>$FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

cp $SCRIPT_DIR mongo.repo /etc/yum.repo.d/mongo.repo
dnf install mongodb-mongosh -y
INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"