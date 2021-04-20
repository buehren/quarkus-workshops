#!/bin/bash

function run
{
    if [ "$#" -lt 4 ]; then
        echo "Usage: gcp-iam-serviceaccount.sh project_id account_name credentials_file role [role...]"
        echo "       - you must be logged in with gcloud auth login when service account needs to be created"
        echo "       - use \$HOME instead of ~ in credentials_file"
        return 1
    fi

    project_id="$1"
    account_name="$2"
    credentials_file="$3"
    shift 3
    roles=( "$@" )

    DIR=$( dirname "${BASH_SOURCE[0]}" )

    echo "project_id=$project_id"
    echo "account_name=$account_name"
    echo "credentials_file=$credentials_file"
    echo "roles=${roles[*]}"

    export GCP_ACCOUNT_EMAIL="$account_name@$project_id.iam.gserviceaccount.com"
    echo "GCP_ACCOUNT_EMAIL=$GCP_ACCOUNT_EMAIL"

    account_exists=$( \
        gcloud iam service-accounts list \
            --project "$project_id" \
            --format="table[no-heading](email)" \
            --filter="email:$GCP_ACCOUNT_EMAIL" \
        | wc -l \
    ) || return
    echo "account_exists=$account_exists"

    if [[ "$account_exists" != "1" ]]; then
        gcloud iam service-accounts create --project "$project_id" "$account_name" || return
        gcloud iam service-accounts describe "$GCP_ACCOUNT_EMAIL" || return
    fi

    $DIR/gcp-iam-roles.sh "$project_id" "$GCP_ACCOUNT_EMAIL" "${roles[@]}" || return
    $DIR/gcp-iam-credentials.sh "$GCP_ACCOUNT_EMAIL" "$credentials_file" || return
}

run "$@" || ( echo "An ERROR occured! $?"; false )
