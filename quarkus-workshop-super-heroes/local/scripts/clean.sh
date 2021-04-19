#!/bin/bash

function run
{
    source superhero-services-env.sh || return

    mkdir -p ui-super-heroes/dist/super-heroes/tmp # because mvn.sh accesses this directory for rest-fight
    SUPERHERO_SERVICES="$SUPERHERO_SERVICES ui-super-heroes" ./mvn.sh "CLEANING" "clean" "$MAVEN_EXTRA_ARGS" || return
}

run || ( echo "An ERROR occured! $?"; false )
