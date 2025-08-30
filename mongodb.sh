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

# === Equivalent of Ansible Tasks ===

# 1. Copy mongo.repo file
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MongoDB Repo file"

# 2. Install MongoDB (dnf)
dnf install -y mongodb-org &>> $LOGFILE
VALIDATE $? "Installed MongoDB"

# 3. Start & enable MongoDB service
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled MongoDB service"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started MongoDB service"

# 4. Enable remote connections (127.0.0.1 → 0.0.0.0)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Enabled remote connections to MongoDB"

# 5. Restart MongoDB service
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted MongoDB service"

echo -e "$G MongoDB setup completed successfully! $N"


