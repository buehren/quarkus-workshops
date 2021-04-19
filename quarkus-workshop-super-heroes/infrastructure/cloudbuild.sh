#!/bin/bash

time gcloud \
    builds submit \
    --project="${GCP_PROJECT_ID}" \
    --gcs-source-staging-dir="gs://${GCP_BUCKET_CLOUDBUILD}/source" \
    --substitutions "BRANCH_NAME=${TERRAFORM_ENVIRONMENT}"

# https://issuetracker.google.com/issues/63480105
#    --region="${GCP_REGION}" \
