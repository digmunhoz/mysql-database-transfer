#! /bin/bash

# Variables
MYSQL_SOURCE_HOST=${MYSQL_SOURCE_HOST:-}
MYSQL_SOURCE_USERNAME=${MYSQL_SOURCE_USERNAME:-}
MYSQL_SOURCE_PASSWORD=${MYSQL_SOURCE_PASSWORD:-}
MYSQL_SOURCE_DATABASE=${MYSQL_SOURCE_DATABASE:-}
DEST_DIR=/tmp/
DATETIME=$(date +%Y%M%d%H%M)
LOG=/tmp/backup.txt
LOGGER_FMT=${LOGGER_FMT:="%Y-%m-%d %H:%M:%S"}

log () {
    if [ $? -eq 0 ];
    then
        echo -e "\e[37m[$( date "+${LOGGER_FMT}" )][INFO] $1\e[0m " 1>&2;
    else
        echo -e "\e[1;31m[$( date "+${LOGGER_FMT}" )][ERROR]\e[0m $1 " 1>&2;
    fi
}

dbBackup () {
    server=$1
    username=$2
    password=$3
    database=$4
    parameters="--routines \
                --events \
                --single-transaction \
                --triggers \
                --extended-insert"
    log "Starting backup using these settings: Host: \"${MYSQL_SOURCE_HOST}\" Username: \"${MYSQL_SOURCE_USERNAME}\" Database: \"${MYSQL_SOURCE_DATABASE}\""
    result=$(($(which mysqldump) ${parameters} -u $2 -p$3 -h $1 $4 > ${DEST_DIR}/$1_$4_${DATETIME}.sql) 2>&1)
    log "Backup finished ${result}"
}

# Parameter 1: Host
# Parameter 2: Username
# Parameter 3: Password
# Parameter 4: Database
dbBackup ${MYSQL_SOURCE_HOST} \
         ${MYSQL_SOURCE_USERNAME} \
         ${MYSQL_SOURCE_PASSWORD} \
         ${MYSQL_SOURCE_DATABASE}