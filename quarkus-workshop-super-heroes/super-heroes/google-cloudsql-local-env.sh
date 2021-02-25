#!/bin/bash

function run
{
    source superhero-services-env.sh || return
    source google-cloudrun-env.sh || return
    source google-cloudsql-env.sh || return
    source kafka-env.sh || return

    # Stop service if it was installed and started
    sudo systemctl stop cloud-sql-proxy

    # Stop previous instance
    pgrep -af "cloud-sql-proxy"
    if [ "$?" == "0" ]; then
        echo "======================================= KILL: cloud-sql-proxy ======================================= " && \
        pkill -ef "cloud-sql-proxy" || return
    fi

    echo "======================================= START: cloud-sql-proxy ======================================= " && \
    echo "Starting cloud-sql-proxy in background"
    # TCP Port:
    cloud-sql-proxy -ip_address_types=PUBLIC -instances="$SERVICE_REST_HERO_DATASOURCE_INSTANCE_CONNECTION_NAME"=tcp:5432 &>> /tmp/cloud-sql-proxy.out &
    # Unix Socket:
    #sudo mkdir -pv /cloudsql
    #sudo chown $USER /cloudsql
    #cloud-sql-proxy -instances=$SERVICE_REST_HERO_DATASOURCE_INSTANCE_CONNECTION_NAME -dir=/cloudsql &>> /tmp/cloud-sql-proxy.out &

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/cloud-sql-proxy.out"
    echo ""
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run || ( echo "An ERROR occured!"; false )
else
    echo "Please start this script with source ..."; false
fi
