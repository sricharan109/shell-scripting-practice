#!/bin/bash
id=$(id -u)
if [ id -ne 0]; then
            echo "try with root user"
            exit 1
fi
ANSER(){
      if [ $1 -ne 0 ]; then
             echo "$2 Installing..........FAILED"
             exit 1
      else
             echo "Installing ...Success"
      fi

      }
dhf install nginx
ANSER $? "Installing nginx"