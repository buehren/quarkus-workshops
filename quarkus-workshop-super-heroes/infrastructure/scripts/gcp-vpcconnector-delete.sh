#!/bin/bash

function run
{
    source ./gcp-env.sh || return

    gcloud compute networks vpc-access connectors list \
      --region=$GCP_REGION \
      || return

    gcloud compute networks vpc-access connectors delete --async vpc-connector \
      --region=$GCP_REGION \
      || return

    gcloud compute networks vpc-access connectors list \
      --region=$GCP_REGION \
      || return
}

run || ( echo "An ERROR occured! $?"; false )
