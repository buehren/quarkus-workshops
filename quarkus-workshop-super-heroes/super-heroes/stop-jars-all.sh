#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES ui-super-heroes; do
        pgrep -af "java .*-jar $service/target/$service-01-runner\.jar"
        if [ "$?" == "0" ]; then
            echo "======================================= KILL JAR: $service ======================================= " && \
            pkill -ef "java .*-jar $service/target/$service-01-runner\.jar" || return
        fi
    done

    sleep 2
    echo "Services still running:"
    pgrep -af "target/.*-01-runner.*"

    return 0
}

run || ( echo "An ERROR occured!"; false )
