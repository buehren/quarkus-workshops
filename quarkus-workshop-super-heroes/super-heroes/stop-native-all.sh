#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
        pgrep -af "$service/target/$service-01-runner[^.]"
        if [ "$?" == "0" ]; then
            echo "======================================= KILL NATIVE: $service ======================================= " && \
            pkill -ef "$service/target/$service-01-runner[^.]" || return
        fi
    done
    sleep 2
    for service in $SUPERHERO_SERVICES; do
        pgrep -af "$service/target/$service-01-runner[^.]"
        if [ "$?" == "0" ]; then
            echo "======================================= KILL -9 NATIVE: $service ======================================= " && \
            pkill -9 -ef "$service/target/$service-01-runner[^.]"  || return
        fi
    done

    sleep 2
    echo "Services still running:"
    pgrep -af "target/.*-01-runner.*"
    
    return 0
}

run || ( echo "An ERROR occured!"; false )
