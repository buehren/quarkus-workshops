#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and build the UI and JARs:
#     ./build-ui.sh
#     ./build-jars-all.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./run-dev-all.sh
# ...and kill the services running in dev mode:
#     ./stop-dev-all.sh

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES ui-super-heroes; do
        echo "======================================= RUN JAR: $service ======================================= " && \
        echo "Starting $service in background"
        java -jar $service/target/$service-01-runner.jar &>> /tmp/$service.jar.out &
    done

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/*.jar.out"
    echo ""

    ./show-urls.sh
}

run || ( echo "An ERROR occured!"; false )
