#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and maybe clean all:
#     ./clean-all.sh
# ...and build the UI:
#     ./build-ui.sh
# ...and create database records (required only once):
#     QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION="drop-and-create" ./run-dev-all.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    ./mvn-all.sh "COMPILING" "compile" "$MAVEN_EXTRA_ARGS"  || return

    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES ui-super-heroes; do
        echo "======================================= START DEV MODE: $service ======================================= " && \
        echo "Starting $service quarkus:dev in background"
        cd $service  || return 1
        # debugHost=0.0.0.0: Listen to all IP addresses when debugging
        # (helpful for running in VM - just as an example for manual calls; debugging is disabled here anyway)
        mvn quarkus:dev -DdebugHost=0.0.0.0 -Ddebug=false &>> /tmp/$service.dev.out &
        cd ..  || return 1
    done

    echo ""
    echo "Log outputs: tail -n 10 -F /tmp/*.dev.out"
    echo ""

    ./show-urls.sh
}

run || ( echo "An ERROR occured!"; false )
