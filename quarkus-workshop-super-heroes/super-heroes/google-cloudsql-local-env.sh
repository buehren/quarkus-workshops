#!/bin/bash

function run
{
    source superhero-services-env.sh
    source google-cloudrun-env.sh
    source google-cloudsql-env.sh
    source kafka-env.sh

    sudo service cloud-sql-proxy start
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run || ( echo "An ERROR occured!"; false )
else
    echo "Please start this script with source ..."; false
fi
