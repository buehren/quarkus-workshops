#!/bin/bash

#oldsetstate="$(set +o)" # POSIXly store all set options.

function set_variables
{
    [[ $_ != $0 ]] || {
        echo "Please start this script like that:"
        echo "    source $0"
        return 1;
    }

    # GCLOUD_PROJECT_ID
    GCLOUD_PROJECT_ID=$( gcloud config list --format 'value(core.project)' )
    echo "GCLOUD_PROJECT_ID=$GCLOUD_PROJECT_ID"
    [ "$GCLOUD_PROJECT_ID" ] || {
        echo "Please login to Google Cloud and set default project id:"
        echo "    gcloud auth login"
        echo "    gcloud config set project PROJECT_ID"
        return 1;
    }
    export GCLOUD_PROJECT_ID

    # GCLOUD_PROJECT_NUMBER
    GCLOUD_PROJECT_NUMBER=$( gcloud projects describe "$GCLOUD_PROJECT_ID" --format 'value(projectNumber)' )
    echo "GCLOUD_PROJECT_NUMBER=$GCLOUD_PROJECT_NUMBER"
    [ "$GCLOUD_PROJECT_NUMBER" ] || return 1
    export GCLOUD_PROJECT_NUMBER

    # GCLOUD_SERVICEACCOUNT
    GCLOUD_SERVICEACCOUNT=$GCLOUD_PROJECT_NUMBER-compute@developer.gserviceaccount.com
    echo "GCLOUD_SERVICEACCOUNT=$GCLOUD_SERVICEACCOUNT"
    export GCLOUD_SERVICEACCOUNT

    # GOOGLE_APPLICATION_CREDENTIALS
    GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/key-serviceaccount-compute-$GCLOUD_PROJECT_ID.json
    echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"
    [ ! -e "$GOOGLE_APPLICATION_CREDENTIALS" ] && {
        echo "Create a credentials file for accessing Google Cloud:";
        echo "    gcloud iam service-accounts keys create $GOOGLE_APPLICATION_CREDENTIALS --iam-account=$GCLOUD_SERVICEACCOUNT";
        return 1;
    }
    ls -l "$GOOGLE_APPLICATION_CREDENTIALS" || return 1
    export GOOGLE_APPLICATION_CREDENTIALS

    # GCLOUD_DB_INSTANCE
    [ "$db_instances" ] || db_instances=$( gcloud sql instances list --format 'value(name)' )
    num_dbs=$( echo "$db_instances" | wc -l )
    [ "$num_dbs" -gt 1 ] && {
        echo "More than 1 DB found in project:"
        echo "$db_instances"
        echo "Set the instance name of the DB to use in GCLOUD_DB_INSTANCE"; \
        return 1;
    }
    GCLOUD_DB_INSTANCE="$db_instances"
    echo "GCLOUD_DB_INSTANCE=$GCLOUD_DB_INSTANCE"
    [ "$GCLOUD_DB_INSTANCE" ] || return 1
    export GCLOUD_DB_INSTANCE

    # GCLOUD_DB_CONNECTION_NAME
    GCLOUD_DB_CONNECTION_NAME=$( gcloud sql instances describe "$GCLOUD_DB_INSTANCE" --format="value(connectionName)" ) || return 1
    echo "GCLOUD_DB_CONNECTION_NAME=$GCLOUD_DB_CONNECTION_NAME"
    [ "$GCLOUD_DB_CONNECTION_NAME" ] || return 1
    export GCLOUD_DB_CONNECTION_NAME

    # GCLOUD_DB_INSTANCE_IP
    GCLOUD_DB_INSTANCE_IP=$(gcloud sql instances describe "$GCLOUD_DB_INSTANCE" --format 'value(ipAddresses.ipAddress)') || return 1
    echo "GCLOUD_DB_INSTANCE_IP=$GCLOUD_DB_INSTANCE_IP"
    [ "$GCLOUD_DB_CONNECTION_NAME" ] || return 1
    export GCLOUD_DB_INSTANCE_IP

    echo "Environment variables set successfully."
}

#set +e

set_variables || ( echo "An ERROR occured!"; false )

#set -vx; eval "$oldsetstate" > /dev/null # restore all options stored.
