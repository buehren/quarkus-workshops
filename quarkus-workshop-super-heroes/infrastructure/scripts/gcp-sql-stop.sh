#!/bin/bash

function run
{
    source ./gcp-env.sh || return
    #source ./gcp-sql-env.sh || return

    # Remove public IP address (reservation of unused public IPs costs)
    gcloud sql instances patch "$GCP_SQLDB_INSTANCE" --no-assign-ip || return
    # Stop database instance
    gcloud sql instances patch "$GCP_SQLDB_INSTANCE" --activation-policy NEVER || return

    gcloud sql instances describe "$GCP_SQLDB_INSTANCE" || return
}

run || ( echo "An ERROR occured! $?"; false )
