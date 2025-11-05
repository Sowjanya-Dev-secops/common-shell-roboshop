#!/bin/bash
create_root(){
    USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.msdevsecops.fun
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi
}

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

nodejs(){
    dnf module disable nodejs -y
    VALIDATE $? "Disable nodejs"  

    dnf module enable nodejs:20 -y
    VALIDATE $? "Enable nodejs"

    dnf install nodejs -y
    VALIDATE $? "Enable nodejs"

}
npm_install(){
    npm install
    VALIDATE $? "install dependencies"
}
app_setup(){
    id roboshop
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating system user"
    else
    echo -e "user already exist....$G Skipping$N"
    fi

    mkdir -p /app 
    VALIDATE $? "creating directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    VALIDATE $? "Downloading the Application"

    cd /app 
    VALIDATE $? "changing directory"

    rm -rf /app/*
    VALIDATE $? "remove old existing code"

    unzip /tmp/$app_name.zip
    VALIDATE $? "unzip the catalouge"
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copy catalouge services"

    systemctl daemon-reload
    systemctl enable catalogue 
    VALIDATE $? "enable catalogue"
}
start_app(){
    systemctl start $app_name
    VALIDATE $? "start $app_name"
}
resatrt_app(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}
