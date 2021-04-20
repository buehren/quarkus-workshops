#!/bin/bash

echo "GCP_PROJECT_ID=${GCP_PROJECT_ID}"
echo "GCP_BUCKET_CLOUDBUILD_SOURCE=${GCP_BUCKET_CLOUDBUILD_SOURCE}"
echo "GCP_BUCKET_CLOUDBUILD_LOG=${GCP_BUCKET_CLOUDBUILD_LOG}"
echo "TERRAFORM_ENVIRONMENT=${TERRAFORM_ENVIRONMENT}"
echo "IMAGE_TAG=${IMAGE_TAG}"
#echo ""
#echo "QUARKUS_PROFILE=${QUARKUS_PROFILE}"

time gcloud \
    builds submit \
    --project="${GCP_PROJECT_ID}" \
    --gcs-source-staging-dir="gs://${GCP_BUCKET_CLOUDBUILD_SOURCE}/source" \
    --gcs-log-dir="gs://${GCP_BUCKET_CLOUDBUILD_SOURCE}/log" \
    --config="deployment/gcp/cloudbuild-deploy.yaml" \
    --ignore-file="deployment/gcp/.gcloudignore.${DOCKERFILE_TYPE-native}" \
    --substitutions="_SERVICE=$( basename $( pwd )),BRANCH_NAME=${TERRAFORM_ENVIRONMENT},COMMIT_SHA=${IMAGE_TAG}" #,_QUARKUS_PROFILE=${QUARKUS_PROFILE}"

# https://issuetracker.google.com/issues/63480105
#    --region="${GCP_REGION}" \
