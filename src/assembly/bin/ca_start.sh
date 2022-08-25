#!/bin/bash

SERVICE_NAME="@project.artifactId@"
VERSION="@project.version@"
SERVICE_LIB_NAME=${SERVICE_NAME}-${VERSION}.jar

PRO_BIN_DIR=$(cd `dirname "$0"`; pwd)
PRO_BASE_DIR=${PRO_BIN_DIR}/..
PRO_CONF_DIR=${PRO_BIN_DIR}/../conf
PRO_LIB_DIR=${PRO_BASE_DIR}/lib
PRO_LOGS_DIR=${PRO_BASE_DIR}/logs
PRO_PID_FILE=$PRO_BIN_DIR/running.pid
PRO_NOHUP_FILE=${PRO_LOGS_DIR}/nohup.out

START_SUCCESS_OUTPUT="The $SERVICE_NAME service is started"
MAX_START_TIME_S=30

JAVA_OPTS="-server -Xms1024m -Xmx2048m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:MaxDirectMemorySize=1024m"
JAVA_HEAP_DUMP_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${PRO_LOGS_DIR}"
JAVA_GC_OPTS="-Xloggc:${PRO_LOGS_DIR}/mananged_gc.log"

while getopts "e:" opt
do
    case $opt in
        e)
            SERVICE_PROFILE=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1;
    esac
done


if [ $SERVICE_PROFILE != 'prd' ]
then
    JAVA_OPTS="-server -Xms256m -Xmx512m -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=256m"
fi

if [ -f "$PRO_PID_FILE" ]; then
    if [ `ps -ef | grep $(cat "$PRO_PID_FILE") | grep $SERVICE_NAME | wc -l` -gt 0 ]
    then
        echo "$SERVICE_NAME is running..."
        exit 0;
    fi
fi

cd $PRO_BASE_DIR

nohup java ${JAVA_OPTS} ${JAVA_HEAP_DUMP_OPTS} ${JAVA_GC_OPTS} \
    -jar ${PRO_BASE_DIR}/lib/${SERVICE_LIB_NAME} \
    --spring.profiles.active=${SERVICE_PROFILE:-default} \
    --spring.config.location=${PRO_CONF_DIR}/ \
    --logging.file=${PRO_LOGS_DIR}/${SERVICE_NAME}.log \
    > ${PRO_BASE_DIR}/logs/nohup.out 2>&1 &

if [ $? -eq 0 ]; then
    if /bin/echo -n $! > "$PRO_PID_FILE"
    then
        if [ `ps -ef | grep $(cat "$PRO_PID_FILE") | grep $SERVICE_NAME | wc -l` -gt 0 ]; then
            echo "${SERVICE_NAME} STARTED"
        else
            echo "FAILED TO START ${SERVICE_NAME}"
            exit 1
        fi
        echo pid[$!]
    else
        echo "FAILED TO WRITE PID"
        exit 1
    fi
else
    echo "${SERVICE_NAME} DID NOT START"
    exit 1
fi