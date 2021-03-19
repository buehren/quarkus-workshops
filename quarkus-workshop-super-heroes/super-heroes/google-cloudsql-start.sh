#!/bin/bash

function run
{
    source ./google-cloudrun-env.sh || return
    #source ./google-cloudsql-env.sh || return

    # Start database instance and assign public IP address
    gcloud sql instances patch "$GCLOUD_DB_INSTANCE" --activation-policy ALWAYS --assign-ip || return

    gcloud sql instances describe "$GCLOUD_DB_INSTANCE" || return
}

run || ( echo "An ERROR occured!"; false )
