#!/bin/bash

function run
{
    source ./google-cloudrun-env.sh || return

    gcloud compute networks vpc-access connectors create my-vpc-connector \
      --network default \
      --range 192.168.200.0/28 \
      --region=$GCLOUD_REGION \
      --min-throughput 200 \
      --max-throughput 300 \
      || return

    gcloud compute networks vpc-access connectors describe my-vpc-connector \
      --region=$GCLOUD_REGION \
      || return
}

run || ( echo "An ERROR occured!"; false )
