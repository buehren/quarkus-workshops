#!/bin/bash

function run
{
    local DIR=$( dirname "${BASH_SOURCE[0]}" )

    echo "WORKING DIRECTORY: "$( pwd )
    if [[ ! $( pwd ) == *"/environments/"* ]]; then
        echo "Must cd to one of the environments subdirectories and call source ../../terraform-env.sh"
        ls -d $DIR/environments/*/
        return 100
    fi
    export TERRAFORM_ENVIRONMENT="$(basename $( pwd ))"
    echo "TERRAFORM_ENVIRONMENT=$TERRAFORM_ENVIRONMENT"

    # Workspaces are currently not used (replaced by environment directories for separate states)
    #terraform_workspace=$( terraform workspace show ) || return 100
    #echo "TERRAFORM WORKSPACE: $terraform_workspace"

    local environment=$( grep -hoP "(?<=environment=\").*(?=\")" terraform.tfvars ) || return 100
    echo "environment=$environment"
    if [[ "$environment" != "$TERRAFORM_ENVIRONMENT" ]]; then
        echo "GCP Project ID from environment variable GCP_PROJECT_ID does not match gcp_project_id from terraform.tfvars"
        echo "    GCP_PROJECT_ID=$GCP_PROJECT_ID"
        echo "    gcp_project_id=$gcp_project_id"
        echo "Please login to Google Cloud and set default project id:"
        echo "    gcloud auth login"
        echo "    gcloud config set project PROJECT_ID"
        return 1
    fi
    echo ""


    # Google Cloud Platform

    source "$DIR"/../../scripts/gcp-env.sh || return 101

    #gcp_project_id=$( grep -oP "(?<=^gcp_project_id=\").*(?=\")" "$terraform_workspace".tfvars ) || return 102
    local gcp_project_id=$( grep -hoP "(?<=gcp_project_id=\").*(?=\")" terraform.tfvars ) || return 102

    if [[ "$gcp_project_id" != "$GCP_PROJECT_ID" ]]; then
        echo "GCP Project ID from environment variable GCP_PROJECT_ID does not match gcp_project_id from terraform.tfvars"
        echo "    GCP_PROJECT_ID=$GCP_PROJECT_ID"
        echo "    gcp_project_id=$gcp_project_id"
        echo "Please login to Google Cloud and set default project id:"
        echo "    gcloud auth login"
        echo "    gcloud config set project PROJECT_ID"
        return 1
    fi


    local gcp_account_name="terraform"
    local gcp_credentials_file="$HOME/.config/gcp/key-serviceaccount-terraform-$gcp_project_id.json"

    export GCP_BUCKETS_LOCATION="eu"


    # Create service account and credentials file for terraform (if required)
    "$DIR"/../../scripts/gcp-iam-serviceaccount.sh \
        "$gcp_project_id" \
        "$gcp_account_name" \
        "$gcp_credentials_file" \
            "roles/editor" \
            "roles/servicenetworking.networksAdmin" \
            "roles/resourcemanager.projectIamAdmin" \
        || return 111

    export GCP_PROJECT_ID="$gcp_project_id"
    echo "GCP_PROJECT_ID=$GCP_PROJECT_ID"
    export GOOGLE_APPLICATION_CREDENTIALS="$gcp_credentials_file"
    echo "GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS"

    echo ""


    # Create Google Cloud Storage Bucket for saving the Terraform state

    GCLOUD_BUCKET_TERRAFORM="${GCP_PROJECT_ID}_${TERRAFORM_ENVIRONMENT}_terraform"
    echo "GCLOUD_BUCKET_TERRAFORM=$GCLOUD_BUCKET_TERRAFORM, location=$GCP_BUCKETS_LOCATION"
    if ! gsutil ls "gs://$GCLOUD_BUCKET_TERRAFORM"; then
        gsutil mb -p "$GCP_PROJECT_ID" -l "$GCP_BUCKETS_LOCATION" "gs://$GCLOUD_BUCKET_TERRAFORM"  || return 121
        gsutil versioning set on "gs://$GCLOUD_BUCKET_TERRAFORM" || return 122
    fi

    echo ""


    # MongoDB Atlas

    # Public and private keys must be added to a file as described in mongodbatlas-env.sh.
    # If secrets do not yet exist in GCP Secret Manager they are created from the keys found in that file (see below).

    #local mongodb_project_id=$( grep -oP "(?<=^mongodbatlas_project_id=\").*(?=\")" "$terraform_workspace".tfvars ) || return 103
    local mongodb_project_id=$( grep -hoP "(?<=mongodbatlas_project_id=\").*(?=\")" terraform.tfvars ) || return 141

    source "$DIR"/../../scripts/mongodbatlas-env.sh "$mongodb_project_id" || return
    # environment variables for Terraform module
    export MONGODB_ATLAS_PROJECT_ID="$ATLAS_PROJECT_ID"
    echo "MONGODB_ATLAS_PROJECT_ID=$MONGODB_ATLAS_PROJECT_ID"
    export MONGODB_ATLAS_PUBLIC_KEY="$ATLAS_PUBLIC_KEY"
    export MONGODB_ATLAS_PRIVATE_KEY="$ATLAS_PRIVATE_KEY"
    echo "MONGODB_ATLAS_PUBLIC_KEY=$MONGODB_ATLAS_PUBLIC_KEY"
    echo "MONGODB_ATLAS_PRIVATE_KEY=..."

    echo ""


    # Confluent Cloud (Apache Kafka)

    # Save username and password in ~/.netrc with "ccloud login -save"

    # Read username and password from ~/.netrc
    CONFLUENT_CLOUD_USERNAME=$( awk '/confluent-cli:ccloud-username-password:/{getline; print $2}' ~/.netrc ) || return 161
    CONFLUENT_CLOUD_PASSWORD=$( awk '/confluent-cli:ccloud-username-password:/{getline; getline; print $2}' ~/.netrc ) || return 162

    # For Terraform provider "confluentcloud"
    export CONFLUENT_CLOUD_USERNAME
    export CONFLUENT_CLOUD_PASSWORD
    echo "CONFLUENT_CLOUD_USERNAME=$CONFLUENT_CLOUD_USERNAME"
    echo "CONFLUENT_CLOUD_PASSWORD=..."

    echo ""


    # Google Cloud Platform: Store credentials for non-GCP services in Secret Manager

    declare -A store_secrets
    store_secrets[MONGODB_ATLAS_PUBLIC_KEY]="terraform_mongodbatlas_publickey"
    store_secrets[MONGODB_ATLAS_PRIVATE_KEY]="terraform_mongodbatlas_privatekey"
    store_secrets[CONFLUENT_CLOUD_USERNAME]="terraform_confluentcloud_username"
    store_secrets[CONFLUENT_CLOUD_PASSWORD]="terraform_confluentcloud_password"

    for secret_env in "${!store_secrets[@]}"; do
        secret_name="${store_secrets[$secret_env]}"
        if ! gcloud --project "$GCP_PROJECT_ID" secrets describe "$secret_name"; then
            if [[ "${!secret_env}" != "" ]]; then

                echo ""
                echo "Storing secret value from environment variable $secret_env in Google Secret Manager as $secret_name"
                echo ""

                gcloud --project "$GCP_PROJECT_ID" \
                    secrets create "$secret_name" \
                    --replication-policy="automatic" \
                || return 151

                echo -n "${!secret_env}" | \
                    gcloud --project "$GCP_PROJECT_ID" \
                        secrets versions add "$secret_name" \
                        --data-file=- \
                || return 152
            else
                echo "Secret does not yet exist. Secret value required as environment variable $secret_env"
                echo ""
                return 153
            fi
        fi
    done
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
