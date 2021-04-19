#!/bin/bash

# Before this, start the infrastructure services:
#     ./start-infrastructure.sh
# ...and create database records (required only once):
#     ./sqldb-tables.sh
# ...and build the UI and JARs:
#     ./build-ui.sh
#     ./build-jars.sh
# ...and kill the services running in dev mode:
#     ./stop-dev.sh

function run
{
    source services-env.sh || return

    for service in $SUPERHERO_SERVICES ui-super-heroes; do
        echo "======================================= RUN JAR: $service ======================================= " && \
        echo "Starting $service in background"
        java $JAVA_EXTRA_ARGS -jar $service/target/quarkus-app/quarkus-run.jar &>> /tmp/$service.jar.out &
    done

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/*.jar.out"
    echo ""

    ./show-urls.sh
}

run || ( echo "An ERROR occured! $?"; false )
