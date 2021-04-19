#!/bin/bash

echo "GCP_PROJECT_ID=${GCP_PROJECT_ID}"
echo "GCP_BUCKET_CLOUDBUILD=${GCP_BUCKET_CLOUDBUILD}"
echo "TERRAFORM_ENVIRONMENT=${TERRAFORM_ENVIRONMENT}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo ""
echo "DOCKERFILE_TYPE=${DOCKERFILE_TYPE:-native}"
#echo "MAVEN_EXTRA_ARGS=${MAVEN_EXTRA_ARGS:-(using default)}"
#echo "QUARKUS_PROFILE=${QUARKUS_PROFILE:-(using default)}"

time gcloud \
    builds submit \
    --project="${GCP_PROJECT_ID}" \
    --gcs-source-staging-dir="gs://${GCP_BUCKET_CLOUDBUILD}/source" \
    --config="deployment/gcp/cloudbuild-build.yaml" \
    --ignore-file="deployment/gcp/.gcloudignore.${DOCKERFILE_TYPE-native}" \
    --substitutions="_SERVICE=$( basename $( pwd )),BRANCH_NAME=${TERRAFORM_ENVIRONMENT},COMMIT_SHA=${IMAGE_TAG},_DOCKERFILE=deployment/docker/Dockerfile.${DOCKERFILE_TYPE:-native}" #,_MAVEN_EXTRA_ARGS=${MAVEN_EXTRA_ARGS},_QUARKUS_PROFILE=${QUARKUS_PROFILE}"

# https://issuetracker.google.com/issues/63480105
#    --region="${GCP_REGION}" \
