#!/bin/bash

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Variables
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

# Validation function
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# Root user check
if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
else
    echo "You are root user"
fi

# === MongoDB Installation Steps ===

# 1. Setup MongoDB Repo file
cat >/etc/yum.repos.d/mongo.repo <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF
VALIDATE $? "Created MongoDB repo file"

# 2. Install MongoDB
dnf install -y mongodb-org &>> $LOGFILE
VALIDATE $? "Installed MongoDB"

# 3. Enable & Start MongoDB service
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled MongoDB service"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started MongoDB service"

# 4. Allow remote connections (127.0.0.1 -> 0.0.0.0)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Configured MongoDB for remote access"

# 5. Restart MongoDB service
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted MongoDB service"

echo -e "$G MongoDB setup completed successfully! $N"



