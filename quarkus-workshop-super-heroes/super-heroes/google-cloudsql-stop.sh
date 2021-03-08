#!/bin/bash

function run
{
    source ./google-cloudsql-env.sh || return

    gcloud sql instances patch "$GCLOUD_DB_INSTANCE" --activation-policy NEVER || return

    gcloud sql instances describe "$GCLOUD_DB_INSTANCE" || return
}

run || ( echo "An ERROR occured!"; false )
