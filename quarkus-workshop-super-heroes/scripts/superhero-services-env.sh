#!/bin/bash

function run
{
    export SUPERHERO_SERVICES_ALL="rest-hero rest-villain rest-fight event-statistics"
    if [[ "$SUPERHERO_SERVICES" == "" ]]; then
        export SUPERHERO_SERVICES=$SUPERHERO_SERVICES_ALL
    fi
    env | grep SUPERHERO_SERVICES | sort
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
