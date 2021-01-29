#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./run-dev-all.sh
# ...and kill the services running in dev mode:
#     ./stop-dev-all.sh
# ...and build the UI and native executables:
#     ./build-ui.sh
#     ./build-native-all.sh
#
# HTML UI is available in the fight service

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
        echo "======================================= $service ======================================= " && \
        echo "Starting $service in background"
        $service/target/$service-01-runner &>> /tmp/$service.native.out &
    done

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/*.native.out"
    echo ""

    ./show-urls.sh
}

run || ( echo "An ERROR occured!"; false )
