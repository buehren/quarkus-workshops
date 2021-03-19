#!/bin/bash

function run
{
    source ./google-cloudrun-env.sh || return
    #source ./google-cloudsql-env.sh || return

    # Remove public IP address (reservation of unused public IPs costs)
    gcloud sql instances patch "$GCLOUD_DB_INSTANCE" --no-assign-ip || return
    # Stop database instance
    gcloud sql instances patch "$GCLOUD_DB_INSTANCE" --activation-policy NEVER || return

    gcloud sql instances describe "$GCLOUD_DB_INSTANCE" || return
}

run || ( echo "An ERROR occured!"; false )
