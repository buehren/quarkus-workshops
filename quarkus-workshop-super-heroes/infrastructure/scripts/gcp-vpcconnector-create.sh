#!/bin/bash

function run
{
    source ./gcp-env.sh || return

    gcloud compute networks vpc-access connectors list \
      --region=$GCP_REGION \
      || return

    gcloud compute networks vpc-access connectors create vpc-connector \
      --network default \
      --range 192.168.200.0/28 \
      --region=$GCP_REGION \
      --min-throughput 200 \
      --max-throughput 300 \
      || return

    gcloud compute networks vpc-access connectors describe vpc-connector \
      --region=$GCP_REGION \
      || return
}

run || ( echo "An ERROR occured! $?"; false )
