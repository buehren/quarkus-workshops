#!/bin/bash

function set_variables
{
    [[ $_ != $0 && "$#" -eq 1 ]] || {
        echo "Please start this script like that:"
        echo "    source $0 servicename"
        return 1;
    }

    [ "$GCLOUD_DB_CONNECTION_NAME" ] || {
        echo "$GCLOUD_DB_CONNECTION_NAME is not set. Run google-cloudrun-env.sh first."
        return 1;
    }

    export DATASOURCE_INSTANCE_CONNECTION_NAME=$GCLOUD_DB_CONNECTION_NAME

    if [[ "$1" == "rest-hero" ]]; then
        export DATASOURCE_DBNAME=heroes_database
        export DATASOURCE_USER=superman
        export DATASOURCE_PWD=superman
    elif [[ "$1" == "rest-villain" ]]; then
        export DATASOURCE_DBNAME=villains_database
        export DATASOURCE_USER=superbad
        export DATASOURCE_PWD=superbad
    elif [[ "$1" == "rest-fight" ]]; then
        export DATASOURCE_DBNAME=fights_database
        export DATASOURCE_USER=superfight
        export DATASOURCE_PWD=superfight
    elif [[ "$1" == "event-statistics" ]]; then
        export DATASOURCE_DBNAME=
        export DATASOURCE_USER=
        export DATASOURCE_PWD=
    else
        echo "Unknown service $1"
        return 1
    fi

    env | grep -E ^DATASOURCE || return 1

    echo "Environment variables set successfully."
}

#set +e

set_variables "$@" || echo "An ERROR occured!"

#set -vx; eval "$oldsetstate" > /dev/null # restore all options stored.
