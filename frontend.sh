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
     echo -e "$2 . FAILURE " | tee -a $FILE
        exit 1
    else
        echo -e "$2 . SUCCESS " | tee -a $FILE
    fi
}
dnf module disable nginx -y &>>$FILE
dnf module enable nginx:1.24 -y &>>$FILE
dnf install nginx -y &>>$FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$FILE
systemctl start nginx 
VALIDATE $? "Enabled and started nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$FILE
VALIDATE $? "Downloaded and unzipped frontend"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarted Nginx"
