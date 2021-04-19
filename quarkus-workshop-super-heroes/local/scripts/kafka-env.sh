#!/bin/bash

function run
{
    source services-env.sh || return

    KAFKA_CLUSTER_BOOTSTRAP_SERVERS=$( sed '1q;d' ~/.kafka-api-key )
    KAFKA_CLUSTER_API_KEY=$( sed '2q;d' ~/.kafka-api-key )
    KAFKA_CLUSTER_API_SECRET=$( sed '3q;d' ~/.kafka-api-key )

    export KAFKA_CLUSTER_BOOTSTRAP_SERVERS
    export KAFKA_CLUSTER_API_KEY
    export KAFKA_CLUSTER_API_SECRET

    for service in $SUPERHERO_SERVICES; do
        # Service name used in environment variables (upcase and "_" instead of "-")
        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        export SERVICE_${SERVICE}_KAFKA_CLUSTER_BOOTSTRAP_SERVERS="$KAFKA_CLUSTER_BOOTSTRAP_SERVERS"
        export SERVICE_${SERVICE}_KAFKA_CLUSTER_API_KEY="$KAFKA_CLUSTER_API_KEY"
        export SERVICE_${SERVICE}_KAFKA_CLUSTER_API_SECRET="$KAFKA_CLUSTER_API_SECRET"
    done

    env | egrep "KAFKA_CLUSTER|CONFLUENT_CLOUD" | sed "s/SECRET=.*/SECRET=.../" | sed "s/PASSWORD=.*/PASSWORD=.../" | sort

    echo "Environment variables set successfully."
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
