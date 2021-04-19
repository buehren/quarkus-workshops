#!/bin/bash

function run
{
    source ./gcp-env.sh || return
    #source ./gcp-sql-env.sh || return

    # Start database instance and assign public IP address
    gcloud sql instances patch "$GCP_SQLDB_INSTANCE" --activation-policy ALWAYS --assign-ip || return

    gcloud sql instances describe "$GCP_SQLDB_INSTANCE" || return
}

run || ( echo "An ERROR occured! $?"; false )
