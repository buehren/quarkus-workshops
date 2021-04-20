#!/bin/bash

# Run before (only required once of when changing the project, e.g. dev/staging/prod):
#    gcloud auth login
#    gcloud config set project PROJECT_ID

function run
{
    local DIR=$( dirname "${BASH_SOURCE[0]}" )

    # Google Cloud Platform

    source "$DIR"/gcp-env.sh || return 101

    gcp_account_name="gitlab-ci"
    gcp_credentials_file="$HOME/.config/gcp/key-serviceaccount-gitlabci-$GCP_PROJECT_ID.json"

    # Create service account and credentials file for GitLab CI (if required)
    source "$DIR"/gcp-iam-serviceaccount.sh \
        "$GCP_PROJECT_ID" \
        "$gcp_account_name" \
        "$gcp_credentials_file" \
            "roles/cloudbuild.builds.editor" \
        || return 111

    # Allow GitLab to write to Storage Bucket for uploading sources to Cloud Build
    gsutil iam ch "serviceAccount:${GCP_ACCOUNT_EMAIL}:roles/storage.admin" "gs://${GCP_BUCKET_CLOUDBUILD_SOURCE}" || return 112

    echo "========================================================================================="
    echo "GitLab CI/CD variables:"
    echo ""
    echo "GCP_REGION: Value: $GCP_REGION"
    echo "GCP_PROJECT_ID: Protected, Environment scope (dev/staging/prod), Value: $GCP_PROJECT_ID"
    echo "GCP_BUCKET_CLOUDBUILD_SOURCE: Protected, Environment scope (dev/staging/prod), Value: $GCP_BUCKET_CLOUDBUILD_SOURCE"
    echo "GCP_SERVICEACCOUNT_KEYFILE: File, Protected, Masked, Environment scope (dev/staging/prod), Value:"
    cat "${gcp_credentials_file}"
    echo "========================================================================================="
    \rm -vf $gcp_credentials_file

    gcloud iam service-accounts keys list --iam-account="${GCP_ACCOUNT_EMAIL}"
    echo "Delete unused keys: gcloud iam service-accounts keys delete --iam-account=${GCP_ACCOUNT_EMAIL}  KEY_ID"
}

run "$@" || ( echo "An ERROR occured! $?"; false )
