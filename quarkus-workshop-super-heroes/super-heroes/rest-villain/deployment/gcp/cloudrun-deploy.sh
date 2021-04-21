#!/bin/bash

function run
{
    if [ "$#" -ne 7 ]; then
        echo "Wrong number of parameters"
        return 1
    fi

    export PROJECT_ID=$1
    export TERRAFORM_ENVIRONMENT=$2
    export SERVICE=$3
    export IMAGE=$4
    export KNATIVE_SERVICE_FILE=$5
    export POLICY_FILE=$6
    export QUARKUS_PROFILE=$7

    # Install envsubst (we could extend the cloud-sdk container image with this to save time on every build)
    apt-get install -y jq gettext-base || return 101

    # Load values like DB connection strings from the Terraform outputs.
    #NOT?:      # - The values can be overwritten by environment variables if required.
    # - The Terraform outputs must be exported to JSON form and saved in Google Cloud Storage after terraform apply.
    # - We do not use the actual default.tfstate file as its format is subject to change.
    # - Secrets are not written to the Terraform outputs and not processed here
    #   but stored in GCP Secrets Manager and retreived at runtime in the service containers (see sm://...).

    # Service name used in environment variables (upcase and "_" instead of "-")
    SERVICE_UPPERCASE=${SERVICE}
    SERVICE_UPPERCASE=${SERVICE_UPPERCASE^^}
    SERVICE_UPPERCASE=${SERVICE_UPPERCASE//-/_}
    export SERVICE_UPPERCASE

    # Service name without "rest-..."
    service_new=${SERVICE}
    service_new=${service_new#rest-}
    service_new=${service_new#event-}
    export service_new

    # Set environment variable with current date and time
    # ${TIMESTAMP} in service.yaml forces a new reviesion in Google Cloud even if nothing else changed
    export TIMESTAMP="$( date +"%Y-%m-%d_%H-%M-%S" )"

    # Set environment variables with Secret Manager "URLs" for berglas
    export "SQLDB_PASSWORD=sm://$PROJECT_ID/service-${service_new}_sqldb-password"
    export "MONGODB_PASSWORD=sm://${PROJECT_ID}/service-${service_new}_mongodb-password"
    export "KAFKA_CLUSTER_API_SECRET=sm://${PROJECT_ID}/service-${service_new}_kafka-apikey-secret"

    # Configuration for reading environment variables from Terraform output
    declare -A JSON_SELECTORS
    # GCP
    JSON_SELECTORS["GCP_REGION"]=".omnibus.value.gcp_region"
    # PostgreSQL
    JSON_SELECTORS["SQLDB_INSTANCE_CONNECTION_NAME"]=".omnibus.value.sqldb_connection_names.${service_new}"
    JSON_SELECTORS["SQLDB_INSTANCE_IP"]=".omnibus.value.sqldb_private_ip_addresses.${service_new}"
    # MongoDB
    JSON_SELECTORS["MONGODB_CONNECTION_STRING"]=".omnibus.value.mongodb_connection_strings.${service_new}"
    # Apache Kafka
    JSON_SELECTORS["KAFKA_CLUSTER_BOOTSTRAP_SERVERS"]=".omnibus.value.kafka_bootstrap_servers | join(\",\")"
    JSON_SELECTORS["KAFKA_CLUSTER_API_KEY"]=".omnibus.value.kafka_apikeys.${service_new}"

    # Read environment variables from Terraform output
    # (existing environment variables are not overwritten!)

    TERRAFORM_OUTPUTS_GS_URL="gs://${PROJECT_ID}_terraform/${TERRAFORM_ENVIRONMENT}/terraform/state/default.tfstate.output.json"
    echo "Terraform Outputs URL: ${TERRAFORM_OUTPUTS_GS_URL}"

    TERRAFORM_OUTPUTS_JSON=$( gsutil cp "${TERRAFORM_OUTPUTS_GS_URL}" - ) || return 111
    echo "$TERRAFORM_OUTPUTS_JSON"

    if [[ "${TERRAFORM_OUTPUTS_JSON}" != "" ]]; then
      for key in "${!JSON_SELECTORS[@]}"; do
          if [[ "${!key-}" == "" ]]; then
              export "$key=$( jq --raw-output "${JSON_SELECTORS[$key]}" <<< "${TERRAFORM_OUTPUTS_JSON}" )" || return 112
              echo "${key}=${!key}"
          else
              echo "Ignoring value for '${key}' from Terraform state! environment variable exists with value '${!key}'"
          fi
      done
    else
      errors=0
      for key in "${!JSON_SELECTORS[@]}"; do
          if [[ "${!key-}" == "" ]]; then
              echo "Environment variable '${key}' does not exist"
              errors=$(( errors+1 ))
          fi
      done
      if [[ errors -gt 0 ]]; then
          echo "Error: TERRAFORM_OUTPUTS_JSON is missing and ${errors} environment variables do not exist."
          return 113
      else
          echo "TERRAFORM_OUTPUTS_JSON is missing, but all values are available as environment variables - proceeding."
      fi
    fi
    echo "Done loading environment variables from Terraform State."


    # TODO: Determine URLs of other services required by this service
    #SERVICE_REST_HERO_URL=$( gcloud run services describe rest-hero --format 'value(status.url)' )
    #SERVICE_REST_VILLAIN_URL=$( gcloud run services describe rest-villain --format 'value(status.url)' )


    # Output environment variables and service configuration
    export

    # Substitute environment variables in Knative configuration YAML file
    KNATIVE_SERVICE_FILE_SUBST=$( envsubst < "${KNATIVE_SERVICE_FILE}" )
    echo "${KNATIVE_SERVICE_FILE_SUBST}"


    # Deploy service to Google Cloud Run. Service/Container configuration in service-*.yaml
    gcloud beta run services replace <(echo -n "${KNATIVE_SERVICE_FILE_SUBST}" ) \
      --platform=managed --region="${GCP_REGION}" \
      || return 201

    # Apply policy (e.g. allow public, unauthenticated access to the service)
    gcloud run services set-iam-policy "${SERVICE}" <(envsubst < "${POLICY_FILE}" ) \
      --platform=managed --region="${GCP_REGION}" \
      || return 202

    # Display deployed service
    gcloud run services list \
      --format yaml --filter metadata.name="${SERVICE}" \
      --platform=managed --region="${GCP_REGION}" \
      || return 203
}

run "$@" || ( echo "An ERROR occured! $?"; false )
