#!/bin/bash

function run
{
    export QUARKUS_PROFILE=googlecloudsql
    export MAVEN_EXTRA_ARGS=-Pgooglecloudsql
    env | egrep "QUARKUS_PROFILE|MAVEN_EXTRA_ARGS"

    echo "Environment variables set successfully."
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured!"; false )
else
    echo "Please start this script with source ..."; false
fi
