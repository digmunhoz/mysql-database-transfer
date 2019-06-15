#! /bin/bash

# Variables
MYSQL_SOURCE_HOST=${MYSQL_SOURCE_HOST:-}
MYSQL_SOURCE_USERNAME=${MYSQL_SOURCE_USERNAME:-}
MYSQL_SOURCE_PASSWORD=${MYSQL_SOURCE_PASSWORD:-}
MYSQL_SOURCE_DATABASE=${MYSQL_SOURCE_DATABASE:-}
MYSQL_DEST_HOST=${MYSQL_DEST_HOST:-}
MYSQL_DEST_USERNAME=${MYSQL_DEST_USERNAME:-}
MYSQL_DEST_PASSWORD=${MYSQL_DEST_PASSWORD:-}
MYSQL_DEST_DATABASE=${MYSQL_DEST_DATABASE:-}
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
    log "Backuping using these settings: Host: \"${MYSQL_SOURCE_HOST}\" Username: \"${MYSQL_SOURCE_USERNAME}\" Database: \"${MYSQL_SOURCE_DATABASE}\""
    result=$(($(which mysqldump) ${parameters} -u $2 -p$3 -h $1 $4 > ${DEST_DIR}/$1_$4_${DATETIME}.sql) 2>&1)
    log "Backuping finished ${result}"
}

dbRestore () {
    server=$1
    username=$2
    password=$3
    database=$4
    log "Dropping database \"${MYSQL_DEST_DATABASE}\" on Host: \"${MYSQL_DEST_HOST}\""
    result=$(($(which mysql) -u $2 -p$3 -h $1 -e "drop database if exists $4;") 2>&1)
    log "Dropping database finished ${result}"
    log "Creating database \"${MYSQL_DEST_DATABASE}\" on Host: \"${MYSQL_DEST_HOST}\""
    result=$(($(which mysql) -u $2 -p$3 -h $1 -e "create database if not exists $4;") 2>&1)
    log "Creating database finished ${result}"
    log "Restoring database using these settings: Host: \"${MYSQL_DEST_HOST}\" Username: \"${MYSQL_DEST_USERNAME}\" Database: \"${MYSQL_DEST_DATABASE}\""
    result=$(($(which mysql) -u $2 -p$3 -h $1 $4 < ${DEST_DIR}/*.sql) 2>&1)
    log "Restore finished ${result}"
}

# Parameter 1: Host
# Parameter 2: Username
# Parameter 3: Password
# Parameter 4: Database
dbBackup ${MYSQL_SOURCE_HOST} \
         ${MYSQL_SOURCE_USERNAME} \
         ${MYSQL_SOURCE_PASSWORD} \
         ${MYSQL_SOURCE_DATABASE}

# Parameter 1: Host
# Parameter 2: Username
# Parameter 3: Password
# Parameter 4: Database
dbRestore ${MYSQL_DEST_HOST} \
          ${MYSQL_DEST_USERNAME} \
          ${MYSQL_DEST_PASSWORD} \
          ${MYSQL_DEST_DATABASE}