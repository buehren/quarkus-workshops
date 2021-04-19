#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

function run
{
    source services-env.sh || return

    for service in $SUPERHERO_SERVICES ui-super-heroes; do
        pgrep -af "$service/target/$service.*\.jar.*"
        if [ "$?" == "0" ]; then
            echo "======================================= KILL JAR: $service ======================================= " && \
            pkill -ef "$service/target/$service.*\.jar.*" || return
        fi
    done

    sleep 2
    echo "Services still running:"
    pgrep -af "target/.*\.jar.*"

    return 0
}

run || ( echo "An ERROR occured! $?"; false )
