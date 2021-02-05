#!/bin/bash

function run
{
    source superhero-services-env.sh || return

    SUPERHERO_SERVICES="$SUPERHERO_SERVICES ui-super-heroes" ./mvn-all.sh "CLEANING" "clean" "$MAVEN_EXTRA_ARGS" || return
}

run || ( echo "An ERROR occured!"; false )
