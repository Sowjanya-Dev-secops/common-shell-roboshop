#!/bin/bash
app_name=catalogue
source ./common.sh
create_root
nodejs
app_setup
npm_install
systemd_setup
start_app
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mongo repo"

dnf install mongodb-mongosh -y
VALIDATE $? "install mongodb"

INDEX=$(mongosh mongodb.msdevsecops.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi
resatrt_app