#!/bin/bash

function run
{
    export QUARKUS_PROFILE=googlecloud
    export MAVEN_EXTRA_ARGS=-Pgooglecloud

    env | egrep "QUARKUS_PROFILE|MAVEN_EXTRA_ARGS" | sort


    # GCP_SQLDB_INSTANCE
    [ "$db_instances" ] || db_instances=$( gcloud sql instances list --format 'value(name)' )
    num_dbs=$( echo "$db_instances" | wc -l )
    [ "$num_dbs" -gt 1 ] && {
        echo "More than 1 DB found in project:"
        echo "$db_instances"
        echo "Set the instance name of the DB to use in GCP_SQLDB_INSTANCE"; \
        return 1;
    }
    GCP_SQLDB_INSTANCE="$db_instances"
    echo "GCP_SQLDB_INSTANCE=$GCP_SQLDB_INSTANCE"
    [ "$GCP_SQLDB_INSTANCE" ] || return 1
    export GCP_SQLDB_INSTANCE

    # GCP_SQLDB_CONNECTION_NAME
    GCP_SQLDB_CONNECTION_NAME=$( gcloud sql instances describe "$GCP_SQLDB_INSTANCE" --format="value(connectionName)" ) || return 1
    echo "GCP_SQLDB_CONNECTION_NAME=$GCP_SQLDB_CONNECTION_NAME"
    [ "$GCP_SQLDB_CONNECTION_NAME" ] || return 1
    export GCP_SQLDB_CONNECTION_NAME

    # GCP_SQLDB_INSTANCE_IP (private IP address)
    GCP_SQLDB_INSTANCE_IP=$(gcloud sql instances describe "$GCP_SQLDB_INSTANCE" --format json | \
        jq --raw-output '.ipAddresses | .[] | select(.type == "PRIVATE") | .ipAddress') || return 1
    echo "GCP_SQLDB_INSTANCE_IP=$GCP_SQLDB_INSTANCE_IP"
    [ "$GCP_SQLDB_CONNECTION_NAME" ] || return 1
    export GCP_SQLDB_INSTANCE_IP


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

    echo "Environment variables set successfully."
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
