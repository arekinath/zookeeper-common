#!/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#
# Common steps to enable a zookeeper service in a zone.

ZK_ROOT=/zookeeper

function zk_common_import
{
    # Install zookeeper package, need to touch this file to disable the license prompt
    touch /opt/local/.dli_license_accepted

    local SVC_ROOT=$1
    local MANIFEST=${SVC_ROOT}/smf/manifests/zookeeper.xml

    svccfg import ${MANIFEST} \
        || fatal "unable to import Zookeeper from ${MANIFEST}"
}

# Sets up delegated dataset at /$ZK_ROOT/zookeeper
function zk_common_delegated_dataset
{
    local ZONE_UUID=$(zonename)
    local ZONE_DATASET=zones/$ZONE_UUID/data
    local mountpoint=

    mountpoint=$(zfs get -H -o value mountpoint $ZONE_DATASET)
    if [[ ${mountpoint} != ${ZK_ROOT} ]]; then
        zfs set mountpoint=${ZK_ROOT} ${ZONE_DATASET} || \
            fatal "failed to set mountpoint"
    fi

    chmod 777 ${ZK_ROOT}
    sudo -u zookeeper mkdir -p ${ZK_ROOT}/zookeeper
}

# sets up hourly log rotation
function zk_common_log_rotation
{
    local PROPERTIES=/opt/local/etc/zookeeper/log4j.properties
    if [[ ! -e $PROPERTIES ]]; then
        echo "No $PROPERTIES file.  Not setting up hourly log rotation."
        return
    fi
    cat >>$PROPERTIES <<"EOF"

#
# Set up hourly log rotation.
# Configuration from zk_common.sh
#
log4j.rootLogger=INFO, LOGFILE
log4j.appender.LOGFILE=org.apache.log4j.FileAppender
log4j.appender.LOGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
log4j.appender.LOGFILE.Append=true
log4j.appender.LOGFILE.Threshold=${zookeeper.log.threshold}
log4j.appender.LOGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.LOGFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n
EOF
}
