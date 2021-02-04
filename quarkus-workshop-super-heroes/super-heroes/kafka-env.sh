#!/bin/bash

function run
{
    KAFKA_CLUSTER_BOOTSTRAP_SERVERS=$( sed '1q;d' ~/.kafka-api-key )
    KAFKA_CLUSTER_API_KEY=$( sed '2q;d' ~/.kafka-api-key )
    KAFKA_CLUSTER_API_SECRET=$( sed '3q;d' ~/.kafka-api-key )

    export KAFKA_CLUSTER_BOOTSTRAP_SERVERS
    export KAFKA_CLUSTER_API_KEY
    export KAFKA_CLUSTER_API_SECRET

    env | egrep "KAFKA_CLUSTER" | sed "s/SECRET=.*/SECRET=.../" | sort

    echo "Environment variables set successfully."
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured!"; false )
else
    echo "Please start this script with source ..."; false
fi
