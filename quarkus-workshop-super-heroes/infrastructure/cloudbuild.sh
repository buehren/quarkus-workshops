#!/bin/bash

echo "GCP_PROJECT_ID=${GCP_PROJECT_ID}"
echo "GCP_BUCKET_CLOUDBUILD_SOURCE=${GCP_BUCKET_CLOUDBUILD_SOURCE}"
echo "GCP_BUCKET_CLOUDBUILD_LOG=${GCP_BUCKET_CLOUDBUILD_LOG}"
echo "TERRAFORM_ENVIRONMENT=${TERRAFORM_ENVIRONMENT}"

time gcloud \
    builds submit \
    --project="${GCP_PROJECT_ID}" \
    --gcs-source-staging-dir="gs://${GCP_BUCKET_CLOUDBUILD_SOURCE}/source" \
    --gcs-log-dir="gs://${GCP_BUCKET_CLOUDBUILD_SOURCE}/log" \
    --substitutions "BRANCH_NAME=${TERRAFORM_ENVIRONMENT}"

# https://issuetracker.google.com/issues/63480105
#    --region="${GCP_REGION}" \
