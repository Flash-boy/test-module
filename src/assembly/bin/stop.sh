#!/bin/bash

SERVICE_NAME="@project.artifactId@"

PRO_BIN_DIR=`dirname "$0"`
PRO_PID_FILE=$PRO_BIN_DIR/running.pid

MAX_STOP_TIME_S=60
MAX_EUREKA_HEARTBEAT=60
SUCCESS=200
PORT=$CONTAINER_SERVER_PORT

if [ -f "$PRO_PID_FILE" ]; then
    if [ `ps -ef | grep $(cat "$PRO_PID_FILE") | grep $SERVICE_NAME | wc -l` -gt 0 ]
    then
        PID=`cat $PRO_PID_FILE`
        kill $PID
        rm $PRO_PID_FILE
        echo "$SERVICE_NAME STOPPED"
        exit 0
    fi
fi
echo "NO INSTANCE OF $SERVICE_NAME IS RUNNING"
