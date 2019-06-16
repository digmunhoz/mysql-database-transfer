#! /bin/bash

# Variables
DEST_TYPE=${DEST_TYPE:-mysql}
AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME:-}
MYSQL_SOURCE_HOST=${MYSQL_SOURCE_HOST:-}
MYSQL_SOURCE_USERNAME=${MYSQL_SOURCE_USERNAME:-}
MYSQL_SOURCE_PASSWORD=${MYSQL_SOURCE_PASSWORD:-}
MYSQL_SOURCE_DATABASE=${MYSQL_SOURCE_DATABASE:-}
MYSQL_DEST_HOST=${MYSQL_DEST_HOST:-}
MYSQL_DEST_USERNAME=${MYSQL_DEST_USERNAME:-}
MYSQL_DEST_PASSWORD=${MYSQL_DEST_PASSWORD:-}
MYSQL_DEST_DATABASE=${MYSQL_DEST_DATABASE:-}
DEST_DIR=/tmp/
DATE=$(date +%Y%m%d)
DATETIME=$(date +%Y%m%d%H%M)
LOG=/tmp/backup.txt
LOGGER_FMT=${LOGGER_FMT:="%Y-%m-%d %H:%M:%S"}

log () {
    if [ $? -eq 0 ];
    then
        echo -e "\e[37m[$( date "+${LOGGER_FMT}" )][INFO] $1\e[0m " 1>&2;
    else
        echo -e "\e[1;31m[$( date "+${LOGGER_FMT}" )][ERROR]\e[0m $1 " 1>&2;
        exit 1;
    fi
}

s3Check () {
    log "Checking if S3 Bucket \"${AWS_S3_BUCKET_NAME}\" exists"
    result=$((aws s3 ls s3://${AWS_S3_BUCKET_NAME}/ > /dev/null) 2>&1)
    log "Existence check finished. ${result}"
    log "Trying to create file on the bucket \"${AWS_S3_BUCKET_NAME}\""
    result=$((aws s3 cp --dryrun /opt/ s3://${AWS_S3_BUCKET_NAME}/ > /dev/null) 2>&1)
    log "Test file finished. ${result}"
}

dbCheck () {
    server=$1
    username=$2
    password=$3
    log "Checking MySQL connectivity on \"$1\""
    result=$(($(which mysql) -u $2 -p$3 -h $1 -e "select 1;" > /dev/null) 2>&1)
    log "Connectivity check finished. ${result}"
}

dbBackup () {
    server=${MYSQL_SOURCE_HOST}
    username=${MYSQL_SOURCE_USERNAME}
    password=${MYSQL_SOURCE_PASSWORD}
    database=${MYSQL_SOURCE_DATABASE}
    parameters="--routines \
                --events \
                --single-transaction \
                --triggers \
                --extended-insert"
    log "Backuping using these settings: Host: \"${server}\" Username: \"${username}\" Database: \"${database}\""
    result=$(($(which mysqldump) ${parameters} -u ${username} -p${password} -h ${server} ${database} > ${DEST_DIR}/$1_$4_${DATETIME}.sql) 2>&1)
    log "Backuping finished ${result}"
}

dbRestore () {
    server=${MYSQL_DEST_HOST}
    username=${MYSQL_DEST_USERNAME}
    password=${MYSQL_DEST_PASSWORD}
    database=${MYSQL_DEST_DATABASE}
    log "Dropping database \"${database}\" on Host: \"${server}\""
    result=$(($(which mysql) -u ${username} -p${password} -h ${server} -e "drop database if exists ${database};") 2>&1)
    log "Dropping database finished. ${result}"
    log "Creating database \"${database}\" on Host: \"${server}\""
    result=$(($(which mysql) -u ${username} -p${password} -h ${server} -e "create database if not exists ${database};") 2>&1)
    log "Creating database finished. ${result}"
    log "Restoring database using these settings: Host: \"${server}\" Username: \"${username}\" Database: \"${database}\""
    result=$(($(which mysql) -u ${username} -p${password} -h ${server} ${database} < ${DEST_DIR}/*.sql) 2>&1)
    log "Restore finished. ${result}"
}

dbS3Copy () {
    bucket=${AWS_S3_BUCKET_NAME}
    log "Copying dump to AWS S3 Bucket: \"${bucket}\""
    result=$((aws s3 cp --storage-class ONE-ZONE_IA /tmp/*.sql s3://${bucket}/${DATE}.sql > /dev/null) 2>&1)
    log "Copying dump to AWS S3 Bucket finished. ${result}"
}

if [ ${DEST_TYPE} == "mysql" ]
then
    dbCheck ${MYSQL_SOURCE_HOST} \
            ${MYSQL_SOURCE_USERNAME} \
            ${MYSQL_SOURCE_PASSWORD}

    dbCheck ${MYSQL_DEST_HOST} \
            ${MYSQL_DEST_USERNAME} \
            ${MYSQL_DEST_PASSWORD}

    dbBackup

    dbRestore

elif [ ${DEST_TYPE} = "s3" ]
then
    dbCheck ${MYSQL_SOURCE_HOST} \
            ${MYSQL_SOURCE_USERNAME} \
            ${MYSQL_SOURCE_PASSWORD}

    s3Check

    dbBackup

    dbS3Copy
fi

