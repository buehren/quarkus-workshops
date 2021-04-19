#!/bin/bash

function run
{
    if [ "$#" -ne 2 ]; then
        echo "Usage: gcp-iam-credentials.sh account_email credentials_file"
        echo "       - you must be logged in with gcloud auth login when service account needs to be created"
        echo "       - use \$HOME instead of ~ in credentials_file"
        return 1
    fi

    account_email="$1"
    credentials_file="$2"

    echo "account_email=$account_email"
    echo "credentials_file=$credentials_file"

    [ ! -e "$credentials_file" ] && {
        gcloud iam service-accounts keys create "$credentials_file" --iam-account="$account_email" || return
    }
    ls -l "$credentials_file" || return
}

run "$@" || ( echo "An ERROR occured! $?"; false )
