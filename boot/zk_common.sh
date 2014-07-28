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
