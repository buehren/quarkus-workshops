#!/bin/bash

# TODO: Rename to cloud instead of cloudrun?

# Run before (only required once of when changing the project, e.g. dev/staging/prod):
#    gcloud auth login
#    gcloud config set project PROJECT_ID


#oldsetstate="$(set +o)" # POSIXly store all set options.

function run
{
    local DIR=$( dirname "${BASH_SOURCE[0]}" )

    # GCP_PROJECT_ID
    GCP_PROJECT_ID=$( gcloud config list --format 'value(core.project)' )
    echo "GCP_PROJECT_ID=$GCP_PROJECT_ID"
    [ "$GCP_PROJECT_ID" ] || {
        echo "Please login to Google Cloud and set default project id:"
        echo "    gcloud auth login"
        echo "    gcloud config set project PROJECT_ID"
        return 1;
    }
    export GCP_PROJECT_ID

    # GCP_PROJECT_NUMBER
    GCP_PROJECT_NUMBER=$( gcloud projects describe "$GCP_PROJECT_ID" --format 'value(projectNumber)' )
    echo "GCP_PROJECT_NUMBER=$GCP_PROJECT_NUMBER"
    [ "$GCP_PROJECT_NUMBER" ] || return 1
    export GCP_PROJECT_NUMBER

    # GCP_REGION
    export GCP_REGION="europe-west1"
    echo "GCP_REGION=$GCP_REGION"

    # GCP_BUCKETS_LOCATION
    export GCP_BUCKETS_LOCATION="eu"
    echo "GCP_BUCKETS_LOCATION=$GCP_BUCKETS_LOCATION"

    echo ""


    # Enable Cloud Resource Manager API (required for enabling APIs) and Secret Manager API
    gcloud --project "$GCP_PROJECT_ID" \
        services enable \
            cloudresourcemanager.googleapis.com \t
            secretmanager.googleapis.com \
        || return 131
    echo ""


    # Create Google Cloud Storage Bucket for uploading sources to Cloud Build

    export GCP_BUCKET_CLOUDBUILD="$GCP_PROJECT_ID"_cloudbuild_source
    echo "GCP_BUCKET_CLOUDBUILD=$GCP_BUCKET_CLOUDBUILD, location=$GCP_BUCKETS_LOCATION"
    if ! gsutil ls "gs://$GCP_BUCKET_CLOUDBUILD"; then
        gsutil mb -p "$GCP_PROJECT_ID" -l "$GCP_BUCKETS_LOCATION" "gs://$GCP_BUCKET_CLOUDBUILD"  || return 121
    fi
    echo ""

    # Allow Cloud Build to publish/update services in Cloud Run
    "$DIR"/gcp-iam-roles.sh "$GCP_PROJECT_ID" \
        "$GCP_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            "roles/run.admin" \
            "roles/iam.serviceAccountUser" \
        || return
    echo ""


    # GCP_SERVICEACCOUNT_COMPUTE
    GCP_SERVICEACCOUNT_COMPUTE=$GCP_PROJECT_NUMBER-compute@developer.gserviceaccount.com
    echo "GCP_SERVICEACCOUNT_COMPUTE=$GCP_SERVICEACCOUNT_COMPUTE"
    export GCP_SERVICEACCOUNT_COMPUTE

    "$DIR"/gcp-iam-roles.sh "$GCP_PROJECT_ID" "$GCP_SERVICEACCOUNT_COMPUTE" \
        "roles/secretmanager.secretAccessor" \
        || return

    # GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE
    GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE="$HOME/.config/gcloud/key-serviceaccount-compute-$GCP_PROJECT_ID.json"
    echo "GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE=$GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE"
    export GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE

    "$DIR"/gcp-iam-credentials.sh "$GCP_SERVICEACCOUNT_COMPUTE" "$GCP_SERVICEACCOUNT_COMPUTE_CREDENTIALS_FILE"

    echo ""



## TODO: Move to google-cloud-sql-firebase.sh? Or leave here and always use owner instead of compute account?
#
#    # GCLOUD_SERVICEACCOUNT_FIREBASE
#    # GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE
#    GCLOUD_SERVICEACCOUNT_FIREBASE_NAME="firebase"
#    GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE="$HOME/.config/gcloud/key-serviceaccount-firebase-$GCP_PROJECT_ID.json"
#
#    ./gcp-iam-serviceaccount.sh \
#        "$GCP_PROJECT_ID" \
#        "$GCLOUD_SERVICEACCOUNT_FIREBASE_NAME" \
#        "$GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE" \
#        "roles/editor" \
#        || return
#
#    export GCLOUD_SERVICEACCOUNT_FIREBASE="$GCLOUD_SERVICEACCOUNT_FIREBASE_NAME@$GCP_PROJECT_ID.iam.gserviceaccount.com"
#    echo "GCLOUD_SERVICEACCOUNT_FIREBASE=$GCLOUD_SERVICEACCOUNT_FIREBASE"
#    export GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE
#    echo "GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE=GCLOUD_SERVICEACCOUNT_FIREBASE_CREDENTIALS_FILE"



    echo "Environment variables set successfully."
}

#set +e

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi

#set -vx; eval "$oldsetstate" > /dev/null # restore all options stored.
