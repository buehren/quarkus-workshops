#!/bin/bash

# Before this build native executables with googlecloudsql profile enabled:
#     ./google-cloudrun-build-native-all.sh

# You should STOP "vagrant rsync-auto" while running this
# to avoid deletion of file in the guest VM when changing files on the host!

function run
{
    source superhero-services-env.sh || return
    source google-cloudrun-env.sh || return
    source google-cloudsql-env.sh || return

    # Build Docker images containing the native executables.
    # We use Google Cloud Build for that but could also do it ourselves.
    for service in $SUPERHERO_SERVICES; do
        echo "======================================= BUILD IMAGE: $service ======================================= " && \

        cd $service  || return 1
        \cp -pfv src/main/docker/Dockerfile.native ./Dockerfile  || return 1
        gcloud builds submit --tag gcr.io/$GCLOUD_PROJECT_ID/$service  || return 1
        cd .. || return 1

        ## JVM instead of native mode:
        ## .gloudignore: comment-out lines with target!
        #
        #./build-ui.sh && ./build-jars-all.sh
        #
        #  cd $service && \
        #  \cp -pfv src/main/docker/Dockerfile.jvm ./Dockerfile && \
        #  gcloud builds submit --tag gcr.io/$GCLOUD_PROJECT_ID/$service && \
    done



    # Deploy Docker images to Google Cloud Run
    for service in $SUPERHERO_SERVICES; do
        echo "======================================= DEPLOY: $service ======================================= " && \

        source google-cloudsql-datasource-env.sh $service  || return 1

        gcloud run deploy $service \
            --image gcr.io/$GCLOUD_PROJECT_ID/$service \
            --platform managed \
            --max-instances=2 \
            --timeout=10 \
            --allow-unauthenticated \
            --add-cloudsql-instances $DATASOURCE_INSTANCE_CONNECTION_NAME \
            --update-env-vars DATASOURCE_INSTANCE_CONNECTION_NAME=$DATASOURCE_INSTANCE_CONNECTION_NAME \
            --update-env-vars DATASOURCE_DBNAME=$DATASOURCE_DBNAME \
            --update-env-vars DATASOURCE_USER=$DATASOURCE_USER \
            --update-env-vars DATASOURCE_PWD=$DATASOURCE_PWD \
            --update-env-vars QUARKUS_PROFILE=googlecloudsql \
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

run || ( echo "An ERROR occured!"; false )
