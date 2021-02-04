#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    ./mvn_all.sh "BUILD NATIVE" "clean package" "-Pnative $MAVEN_EXTRA_ARGS"
}

run || ( echo "An ERROR occured!"; false )
