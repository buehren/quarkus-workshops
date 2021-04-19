#!/bin/bash

# 1. Build Docker images containing the native executables in Google Cloud Build
#    (we could also do that locally but it requires a lot of RAM and CPU)
#    and push the images to Google Container Registry.
#
# 2. Deploy services to Google Cloud Run (we could also do that locally).
#    Images must be built before.

# Usage:
# - no parameters:
#     build service(s) as native binaries, build and push container images, deploy services to Cloud Run
# - first parameter:
#     build: build service(s), build and push container images
#     deploy: deploy services to Cloud Run - images must be built before, set COMMIT_SHA=... to the image tag to use
#     "": both
# - second parameter:
#     native: build/deploy native services
#     native-nopackage: build/deploy native services, native runnables must be created in the project directory before  (currently untested)
#     jvm: build/deploy JVM services (currently broken, at least memory limits in service.yml must be modified)

function run
{
    target="$1"
    DOCKERFILE_TYPE="${2:-native}"  # If parameter not set or null, use native. See build-docker.sh for options!

    # Set required variables if not available as environment variables
    BRANCH_NAME="${BRANCH_NAME:-dev}"
    COMMIT_SHA="${COMMIT_SHA:-manualbuild_$( date +"%Y-%m-%d_%H-%M-%S" )}"

    source superhero-services-env.sh || return
#    source gcp-env.sh || return
#    source gcp-sql-env.sh || return
#    source kafka-env.sh || return


    if [[ "$target" == "" || $target == "build" ]]; then
        run_inner build || return
    fi
    if [[ "$target" == "" || $target == "deploy" ]]; then
        run_inner deploy || return
    fi
}


function run_inner
{
    target_inner="$1"

    for service in $SUPERHERO_SERVICES; do
        echo "======================================= $target_inner: $service ($DOCKERFILE_TYPE) ======================================= " && \

        if [[ "$target_inner" == "build" && "$service" == "rest-fight" ]]; then
            mkdir -p rest-fight/src/main/resources/META-INF/resources || return
            cp -Rvp ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
                echo "UI not found: Run ./build-ui.sh"
                return 101;
            }
        fi

        cd "$service"  || return 102

        # Call cloudbuild script of current service
        deployment/gcp/cloudbuild-"$target_inner".sh

        # Service name used in environment variables (upcase and "_" instead of "-")
        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

#        QUARKUS_PROFILE=googlecloud
#
#        var_mongodb_connection_string=SERVICE_${SERVICE}_MONGODB_CONNECTION_STRING
#        var_sqldb_connection_name=SERVICE_${SERVICE}_SQLDB_INSTANCE_CONNECTION_NAME
#        var_sqldb_instance_ip=SERVICE_${SERVICE}_SQLDB_INSTANCE_IP
#        var_kafka_cluster_bootstrap_servers=SERVICE_${SERVICE}_KAFKA_CLUSTER_BOOTSTRAP_SERVERS
#        var_kafka_cluster_api_key=SERVICE_${SERVICE}_KAFKA_CLUSTER_API_KEY
#
#            "_SERVICE=${service},"
#            "_REGION=${GCP_REGION},"
#            "_KNATIVE_SERVICE_FILE=deployment/knative/service-${DOCKERFILE_TYPE}.yaml,"
#            "_POLICY_FILE=deployment/gcp/policy.yaml,"
#            "_MAVEN_EXTRA_ARGS=${MAVEN_EXTRA_ARGS},"
#            "_QUARKUS_PROFILE=${QUARKUS_PROFILE},"
#            "_SERVICE_${SERVICE}_MONGODB_CONNECTION_STRING=${!var_mongodb_connection_string},"
#            "_SERVICE_${SERVICE}_SQLDB_INSTANCE_CONNECTION_NAME=${!var_sqldb_connection_name},"
#            "_SERVICE_${SERVICE}_SQLDB_INSTANCE_IP=${!var_sqldb_instance_ip},"
#            "_SERVICE_${SERVICE}_KAFKA_CLUSTER_BOOTSTRAP_SERVERS=${!var_kafka_cluster_bootstrap_servers},"
#            "_SERVICE_${SERVICE}_KAFKA_CLUSTER_API_KEY=${!var_kafka_cluster_api_key},"

#        substitutions=(
#            "_SERVICE=${service},"
#            "BRANCH_NAME=${BRANCH_NAME},"
#            "COMMIT_SHA=${COMMIT_SHA},"
#        )
#
#        if [[ "$target_inner" == "build" ]]; then
#            substitutions+=("_DOCKERFILE=deployment/docker/Dockerfile.${DOCKERFILE_TYPE},")
#        fi
#
#        echo "$( date ) $target_inner: gcloud builds submit"
#
#        time gcloud \
#            builds submit \
#            --project="${GCP_PROJECT_ID}" \
#            --region="${GCP_REGION}" \
#            --gcs-source-staging-dir="gs://${GCP_BUCKET_CLOUDBUILD}/source" \
#            --config="deployment/gcp/cloudbuild-${target_inner}.yaml" \
#            --ignore-file="deployment/gcp/.gcloudignore.${DOCKERFILE_TYPE}" \
#            --substitutions=$( concat "${substitutions[@]}" ) \
#            || return 111
#
#        echo "$( date ) $target_inner: gcloud builds submit done"

        cd .. || return 121

        if [[ "$target_inner" == "build" && "$service" == "rest-fight" ]]; then
            ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
                echo "UI no longer found after build: Maybe it was deleted by rsync?"
                return 131;
            }
        fi

        if [[ "$target_inner" == "deploy" ]]; then
            # Determine URL of service
            URL=$( gcloud --project="${GCP_PROJECT_ID}" run services list --filter metadata.name="$service" --format 'value(status.url)' )
            export "SERVICE_${SERVICE}_URL=$URL"
        fi

    done

    if [[ "$target_inner" == "deploy" ]]; then
        # Display deployed services
        gcloud --project="${GCP_PROJECT_ID}" run services list || return 142

        # Display URLs of services
        set | grep -e "^SERVICE_.*_URL" || return 143

        # Display URLs for the browser
        echo -e "$SERVICE_REST_FIGHT_URL/super-heroes/index.html   <<<<<<<<<< PLAY HERE" \
            "\n""$SERVICE_EVENT_STATISTICS_URL/                    <<<<<<<<<< AND WATCH THIS"
    fi

}


concat () (
    IFS=
    printf '%s'"$*"
)



#    DOCKERFILE_TYPE="${1:-native}"  # If parameter not set or null, use native. See build-docker.sh for options!
#
#    source superhero-services-env.sh || return
#    source gcp-env.sh || return
#    source gcp-sql-env.sh || return
#    source kafka-env.sh || return
#
#    # Build Docker images containing the native executables.
#    # We use Google Cloud Build for that but could also do it ourselves.
#    for service in $SUPERHERO_SERVICES; do
#        echo "======================================= BUILD $DOCKERFILE_TYPE IMAGE: $service ======================================= " && \
#        if [ "$service" == "rest-fight" ]; then
#            mkdir -p rest-fight/src/main/resources/META-INF/resources || return
#            cp -Rvp ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
#                echo "UI not found: Run ./build-ui.sh"
#                return 1;
#            }
#        fi
#
#        cd $service  || return 1
#        \cp -pfv deployment/docker/Dockerfile.$DOCKERFILE_TYPE ./Dockerfile  || return 1
#        \cp -pfv src/main/gcp/cloudbuild.yaml ./cloudbuild.yaml  || return 1
#        \cp -pfv src/main/gcp/.gcloudignore.$DOCKERFILE_TYPE ./.gcloudignore  || return 1
#        gcloud builds submit \
#            --config=cloudbuild.yaml \
#            --substitutions \
#                _SERVICE="$service",_MAVEN_EXTRA_ARGS="$MAVEN_EXTRA_ARGS",_QUARKUS_PROFILE="$QUARKUS_PROFILE" \
#            || return 1
#            #--region="$GCP_REGION" \
#
#        #gcloud builds submit --tag eu.gcr.io/$GCP_PROJECT_ID/$service  || return 1
#        cd .. || return 1
#
#        if [ "$service" == "rest-fight" ]; then
#            ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
#                echo "UI no longer found after build: Maybe it was deleted by rsync?"
#                return 1;
#            }
#        fi
#    done
#
#    # Deploy Docker images to Google Cloud Run
#    for service in $SUPERHERO_SERVICES; do
#        echo "======================================= DEPLOY $DOCKERFILE_TYPE IMAGE: $service ======================================= " && \
#
#        # Service name used in environment variables (upcase and "_" instead of "-")
#        SERVICE=${service^^}
#        SERVICE=${SERVICE//-/_}
#
#        # limit timeout etc. to prevent unexpected billing of long execution times
#        var_timeout=10
#        var_memory=256Mi
#        if [ "$DOCKERFILE_TYPE" == "jvm" ]; then
#            # not too short to allow startup of JVM (native starts much faster)
#            var_timeout=40
#            var_memory=512Mi
#        fi
#        if [ "$service" == "rest-hero" ]; then
#            # extended timeout for long running http response or server sent events (SSE) or websockets
#            var_timeout=300
#        fi
#        if [ "$service" == "event-statistics" ]; then
#            # extended timeout for event-statistics websockets
#            var_timeout=300
#        fi
#
#        var_sqldb_connection_name=SERVICE_${SERVICE}_SQLDB_INSTANCE_CONNECTION_NAME
#        var_sqldb_instance_ip=SERVICE_${SERVICE}_SQLDB_INSTANCE_IP
#        var_SQLDB_PASSWORD=SERVICE_${SERVICE}_SQLDB_PASSWORD
#
#        gcloud run deploy $service \
#            --image eu.gcr.io/$GCP_PROJECT_ID/$service \
#            --platform managed \
#            --vpc-connector vpc-connector \
#            --memory=$var_memory \
#            --timeout=$var_timeout \
#            --concurrency=50 \
#            --max-instances=2 \
#            --allow-unauthenticated \
#            --add-cloudsql-instances $SQLDB_INSTANCE_CONNECTION_NAME \
#            --update-env-vars SERVICE_${SERVICE}_SQLDB_INSTANCE_CONNECTION_NAME=${!var_sqldb_connection_name} \
#            --update-env-vars SERVICE_${SERVICE}_SQLDB_INSTANCE_IP=${!var_sqldb_instance_ip} \
#            --update-env-vars SERVICE_${SERVICE}_SQLDB_PASSWORD=${!var_SQLDB_PASSWORD} \
#            --update-env-vars SERVICE_${SERVICE}_KAFKA_CLUSTER_BOOTSTRAP_SERVERS=${KAFKA_CLUSTER_BOOTSTRAP_SERVERS} \
#            --update-env-vars SERVICE_${SERVICE}_KAFKA_CLUSTER_API_KEY=${KAFKA_CLUSTER_API_KEY} \
#            --update-env-vars SERVICE_${SERVICE}_KAFKA_CLUSTER_API_SECRET=${KAFKA_CLUSTER_API_SECRET} \
#            --update-env-vars QUARKUS_PROFILE=googlecloud \
#             || return 1
#    done
#
#    # Display deployed services
#    for service in $SUPERHERO_SERVICES; do
#      gcloud run services describe $service
#    done
#
#    # Determine URLs of services
#    for service in $SUPERHERO_SERVICES_ALL; do
#        URL=$( gcloud run services describe $service --format 'value(status.url)' )
#
#        SERVICE=${service^^}
#        SERVICE=${SERVICE//-/_}
#
#        declare "SERVICE_${SERVICE}_URL=$URL"
#    done
#    set | grep -e "^SERVICE_.*_URL" || return 1
#
#    # Inject the URLs of the Hero and Villain services into the Fights service
#    gcloud run services update rest-fight \
#      --update-env-vars SERVICE_REST_HERO_URL=$SERVICE_REST_HERO_URL, \
#      --update-env-vars SERVICE_REST_VILLAIN_URL=$SERVICE_REST_VILLAIN_URL \
#      || return 1
#
#    gcloud run services list
#
#    # Display URLs for the browser
#    echo -e "$SERVICE_REST_FIGHT_URL/super-heroes/index.html   <<<<<<<<<< PLAY HERE" \
#        "\n""$SERVICE_EVENT_STATISTICS_URL/                    <<<<<<<<<< AND WATCH THIS"


run "$1" || ( echo "An ERROR occured! $?"; false )
