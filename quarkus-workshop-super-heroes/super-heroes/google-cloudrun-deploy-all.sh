#!/bin/bash

# Before this build native executables with googlecloud profile enabled:
#     ./google-cloudrun-build-native-all.sh

# You should STOP "vagrant rsync-auto" while running this
# to avoid deletion of file in the guest VM when changing files on the host!

function run
{
    DOCKERFILE_TYPE="${1:-native}"  # If parameter not set or null, use native.

    source superhero-services-env.sh || return
    source google-cloudrun-env.sh || return
    source google-cloudsql-env.sh || return
    source kafka-env.sh || return

    # Build Docker images containing the native executables.
    # We use Google Cloud Build for that but could also do it ourselves.
    for service in $SUPERHERO_SERVICES; do
        echo "======================================= BUILD $DOCKERFILE_TYPE IMAGE: $service ======================================= " && \

        cd $service  || return 1
        \cp -pfv src/main/docker/Dockerfile.$DOCKERFILE_TYPE ./Dockerfile  || return 1
        \cp -pfv src/main/gcloud/.gcloudignore.$DOCKERFILE_TYPE ./.gcloudignore  || return 1
        gcloud builds submit --tag gcr.io/$GCLOUD_PROJECT_ID/$service  || return 1
        cd .. || return 1
    done

    # Deploy Docker images to Google Cloud Run
    for service in $SUPERHERO_SERVICES; do
        echo "======================================= DEPLOY $DOCKERFILE_TYPE IMAGE: $service ======================================= " && \

        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        # limit timeout etc. to prevent unexpected billing of long execution times
        var_timeout=10
        var_memory=256Mi
        if [ "$DOCKERFILE_TYPE" == "jvm" ]; then
            # not too short to allow startup of JVM (native starts much faster)
            var_timeout=40
            var_memory=512Mi
        fi
        if [ "$service" == "rest-hero" ]; then
            # extended timeout for long running http response or server sent events (SSE) or websockets
            var_timeout=300
        fi
        if [ "$service" == "event-statistics" ]; then
            # extended timeout for event-statistics websockets
            var_timeout=300
        fi

        var_datasource_connection_name=SERVICE_${SERVICE}_DATASOURCE_INSTANCE_CONNECTION_NAME
        var_datasource_dbname=SERVICE_${SERVICE}_DATASOURCE_DBNAME
        var_datasource_user=SERVICE_${SERVICE}_DATASOURCE_USER
        var_datasource_pwd=SERVICE_${SERVICE}_DATASOURCE_PWD

        gcloud run deploy $service \
            --image gcr.io/$GCLOUD_PROJECT_ID/$service \
            --platform managed \
            --memory=$var_memory \
            --timeout=$var_timeout \
            --concurrency=50 \
            --max-instances=2 \
            --allow-unauthenticated \
            --add-cloudsql-instances $DATASOURCE_INSTANCE_CONNECTION_NAME \
            --update-env-vars SERVICE_${SERVICE}_DATASOURCE_INSTANCE_CONNECTION_NAME=${!var_datasource_connection_name} \
            --update-env-vars SERVICE_${SERVICE}_DATASOURCE_DBNAME=${!var_datasource_dbname} \
            --update-env-vars SERVICE_${SERVICE}_DATASOURCE_USER=${!var_datasource_user} \
            --update-env-vars SERVICE_${SERVICE}_DATASOURCE_PWD=${!var_datasource_pwd} \
            --update-env-vars KAFKA_CLUSTER_BOOTSTRAP_SERVERS=${KAFKA_CLUSTER_BOOTSTRAP_SERVERS} \
            --update-env-vars KAFKA_CLUSTER_API_KEY=${KAFKA_CLUSTER_API_KEY} \
            --update-env-vars KAFKA_CLUSTER_API_SECRET=${KAFKA_CLUSTER_API_SECRET} \
            --update-env-vars QUARKUS_PROFILE=googlecloud \
             || return 1
    done

    # Display deployed services
    for service in $SUPERHERO_SERVICES; do
      gcloud run services describe $service
    done

    # Determine URLs of services
    for service in $SUPERHERO_SERVICES_ALL; do
        URL=$( gcloud run services describe $service --format 'value(status.url)' )

        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        declare "SERVICE_${SERVICE}_URL=$URL"
    done
    set | grep -e "^SERVICE_.*_URL" || return 1

    # Inject the URLs of the Hero and Villain services into the Fights service
    gcloud run services update rest-fight \
      --update-env-vars SERVICE_REST_HERO_URL=$SERVICE_REST_HERO_URL, \
      --update-env-vars SERVICE_REST_VILLAIN_URL=$SERVICE_REST_VILLAIN_URL \
      || return 1

    gcloud run services list

    # Display URLs for the browser
    echo -e "$SERVICE_REST_FIGHT_URL/super-heroes/index.html   <<<<<<<<<< PLAY HERE" \
        "\n""$SERVICE_EVENT_STATISTICS_URL/                    <<<<<<<<<< AND WATCH THIS"
}

run "$1" || ( echo "An ERROR occured!"; false )
