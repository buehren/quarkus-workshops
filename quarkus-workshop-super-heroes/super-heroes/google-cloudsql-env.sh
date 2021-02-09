#!/bin/bash

function run
{
    export QUARKUS_PROFILE=googlecloud
    export MAVEN_EXTRA_ARGS=-Pgooglecloud

    env | egrep "QUARKUS_PROFILE|MAVEN_EXTRA_ARGS" | sort

    DATASOURCE_INSTANCE_CONNECTION_NAME=$GCLOUD_DB_CONNECTION_NAME
    DATASOURCE_INSTANCE_IP=$GCLOUD_DB_INSTANCE_IP

    export SERVICE_REST_HERO_DATASOURCE_INSTANCE_CONNECTION_NAME=$DATASOURCE_INSTANCE_CONNECTION_NAME
    export SERVICE_REST_HERO_DATASOURCE_INSTANCE_IP=$DATASOURCE_INSTANCE_IP
    export SERVICE_REST_HERO_DATASOURCE_DBNAME=heroes_database
    export SERVICE_REST_HERO_DATASOURCE_USER=superman
    export SERVICE_REST_HERO_DATASOURCE_PWD=superman

    export SERVICE_REST_VILLAIN_DATASOURCE_INSTANCE_CONNECTION_NAME=$DATASOURCE_INSTANCE_CONNECTION_NAME
    export SERVICE_REST_VILLAIN_DATASOURCE_INSTANCE_IP=$DATASOURCE_INSTANCE_IP
    export SERVICE_REST_VILLAIN_DATASOURCE_DBNAME=villains_database
    export SERVICE_REST_VILLAIN_DATASOURCE_USER=superbad
    export SERVICE_REST_VILLAIN_DATASOURCE_PWD=superbad

    export SERVICE_REST_FIGHT_DATASOURCE_INSTANCE_CONNECTION_NAME=$DATASOURCE_INSTANCE_CONNECTION_NAME
    export SERVICE_REST_FIGHT_DATASOURCE_INSTANCE_IP=$DATASOURCE_INSTANCE_IP
    export SERVICE_REST_FIGHT_DATASOURCE_DBNAME=fights_database
    export SERVICE_REST_FIGHT_DATASOURCE_USER=superfight
    export SERVICE_REST_FIGHT_DATASOURCE_PWD=superfight

    export SERVICE_EVENT_STATISTICS_DATASOURCE_INSTANCE_CONNECTION_NAME=
    export SERVICE_EVENT_STATISTICS_DATASOURCE_INSTANCE_IP=
    export SERVICE_EVENT_STATISTICS_DATASOURCE_DBNAME=
    export SERVICE_EVENT_STATISTICS_DATASOURCE_USER=
    export SERVICE_EVENT_STATISTICS_DATASOURCE_PWD=

    env | egrep "SERVICE_.*_DATASOURCE_.*" | sed "s/PWD=.*/PWD=.../" | sort

    echo "Environment variables set successfully."
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured!"; false )
else
    echo "Please start this script with source ..."; false
fi
