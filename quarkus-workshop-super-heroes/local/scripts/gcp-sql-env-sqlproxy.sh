#!/bin/bash

function run
{
    source services-env.sh || return
    source gcp-env.sh || return
    source gcp-sql-env.sh || return
    source kafka-env.sh || return


    # Set environment variables for accessing GCP Cloud SQL instance
    # TODO: Combine with deployment/gcp/cloudrun-deploy.sh to read values from Terraform Output / Google Secrets Manager

    export SERVICE_REST_HERO_SQLDB_INSTANCE_CONNECTION_NAME=$GCP_SQLDB_CONNECTION_NAME
    export SERVICE_REST_HERO_SQLDB_INSTANCE_IP=$GCP_SQLDB_INSTANCE_IP
    export SERVICE_REST_HERO_SQLDB_PASSWORD=service_hero-password

    export SERVICE_REST_VILLAIN_SQLDB_INSTANCE_CONNECTION_NAME=$GCP_SQLDB_CONNECTION_NAME
    export SERVICE_REST_VILLAIN_SQLDB_INSTANCE_IP=$GCP_SQLDB_INSTANCE_IP
    export SERVICE_REST_VILLAIN_SQLDB_PASSWORD=service_villain-password

    export SERVICE_REST_FIGHT_SQLDB_INSTANCE_CONNECTION_NAME=$GCP_SQLDB_CONNECTION_NAME
    export SERVICE_REST_FIGHT_SQLDB_INSTANCE_IP=$GCP_SQLDB_INSTANCE_IP
    export SERVICE_REST_FIGHT_SQLDB_PASSWORD=service_fight-password

    export SERVICE_EVENT_STATISTICS_SQLDB_INSTANCE_CONNECTION_NAME=
    export SERVICE_EVENT_STATISTICS_SQLDB_INSTANCE_IP=
    export SERVICE_EVENT_STATISTICS_SQLDB_PASSWORD=

    env | egrep "SERVICE_.*_SQLDB_.*" | sed "s/PWD=.*/PWD=.../" | sort



    # Change environment variables SERVICE_*_SQLDB_INSTANCE_IP to 127.0.0.1
    for service in $SUPERHERO_SERVICES_ALL; do

        # Service name used in environment variables (upcase and "_"   instead of "-")
        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        var_sqldb_instance_ip=SERVICE_${SERVICE}_SQLDB_INSTANCE_IP

        export "${var_sqldb_instance_ip}"=127.0.0.1
        env | grep "${var_sqldb_instance_ip}"
    done


    # Stop cloud-sql-proxy if it was started as service (we start it manually)
    sudo systemctl stop cloud-sql-proxy || return

    # Stop previous instance
    pgrep -af "cloud-sql-proxy"
    if [ "$?" == "0" ]; then
        echo "======================================= KILL: cloud-sql-proxy ======================================= " && \
        pkill -ef "cloud-sql-proxy" || return
    fi

    echo "======================================= START: cloud-sql-proxy ======================================= " && \
    echo "Starting cloud-sql-proxy in background"

        # cloud-sql-proxy can also be run in a Container:
        #docker run \
        #  --rm \
        #  -p 127.0.0.1:5432:3306 \
        #  -v /var/svc_account_key.json:/key.json:ro \
        #  gcr.io/cloudsql-docker/gce-proxy:latest /cloud_sql_proxy \
        #    -credential_file=/key.json
        #    -ip_address_types=PRIVATE
        #    -instances=${db_instance_name}=tcp:0.0.0.0:3306

    # TCP Port:
    cloud-sql-proxy -ip_address_types=PUBLIC -instances="$SERVICE_REST_HERO_SQLDB_INSTANCE_CONNECTION_NAME"=tcp:5432 &>> /tmp/cloud-sql-proxy.out &
    # Unix Socket:
    #sudo mkdir -pv /cloudsql
    #sudo chown $USER /cloudsql
    #cloud-sql-proxy -instances=$SERVICE_REST_HERO_SQLDB_INSTANCE_CONNECTION_NAME -dir=/cloudsql &>> /tmp/cloud-sql-proxy.out &

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/cloud-sql-proxy.out"
    echo ""
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
