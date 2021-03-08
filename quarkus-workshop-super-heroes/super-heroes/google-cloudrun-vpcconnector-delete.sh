#!/bin/bash

function run
{
    source ./google-cloudrun-env.sh || return

    gcloud compute networks vpc-access connectors delete --async my-vpc-connector \
      --region=$GCLOUD_REGION \
      || return
}

run || ( echo "An ERROR occured!"; false )
