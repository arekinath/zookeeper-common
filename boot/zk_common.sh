#!/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

function setup_zk_delegated_dataset
{
    local ZK_ROOT=$1
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

    # accept the licence
    touch /opt/local/.dli_license_accepted
}
