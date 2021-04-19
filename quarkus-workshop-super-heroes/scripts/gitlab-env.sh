#!/bin/bash

# Run before (only required once of when changing the project, e.g. dev/staging/prod):
#    gcloud auth login
#    gcloud config set project PROJECT_ID

function run
{
    # Google Cloud Platform

    source ./gcp-env.sh || return 101

    gcp_account_name="gitlab-ci"
    gcp_credentials_file="$HOME/.config/gcp/key-serviceaccount-gitlabci-$GCP_PROJECT_ID.json"

    # Create service account and credentials file for GitLab CI (if required)
    ./gcp-iam-serviceaccount.sh \
        "$GCP_PROJECT_ID" \
        "$gcp_account_name" \
        "$gcp_credentials_file" \
            "roles/cloudbuild.builds.editor" \
        || return 111

    echo "========================================================================================="
    echo "GitLab CI/CD variables:"
    echo ""
    echo "GCP_REGION: Value: $GCP_REGION"
    echo "GCP_PROJECT_ID: Protected, Environment scope (dev/staging/prod), Value: $GCP_PROJECT_ID"
    echo "GCP_BUCKET_CLOUDBUILD: Protected, Environment scope (dev/staging/prod), Value: $GCP_BUCKET_CLOUDBUILD"
    echo "GCP_SERVICEACCOUNT_KEYFILE: File, Protected, Masked, Environment scope (dev/staging/prod), Value:"
    cat "${gcp_credentials_file}"
    echo "========================================================================================="
    \rm -vf $gcp_credentials_file

    account_email="$gcp_account_name@$GCP_PROJECT_ID.iam.gserviceaccount.com"
    gcloud iam service-accounts keys list --iam-account="$account_email"
    echo "Delete unused keys: gcloud iam service-accounts keys delete --iam-account=$account_email  KEY_ID"
}

run "$@" || ( echo "An ERROR occured! $?"; false )
