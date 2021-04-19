#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

function run
{
    docker-compose stop $SUPERHERO_SERVICES

    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
        pgrep -af "$service/target/$service-01-runner.*"
        if [ "$?" == "0" ]; then
            echo "======================================= KILL -9: $service ======================================= " && \
            pkill -9 -ef "$service/target/$service-01-runner.*" || return
        fi
    done

    return 0
}

run || ( echo "An ERROR occured! $?"; false )
