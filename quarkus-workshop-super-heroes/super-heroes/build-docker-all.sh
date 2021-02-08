#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh
# ...and either build JARs (then start this script with parameter "jvm"):
#     ./build-jars-all.sh
# ...or build native executables  (then start this script with parameter "native" or without parameter):
#     ./build-native-all.sh


function run
{
    DOCKERFILE_TYPE="${1:-native}"  # If parameter not set or null, use native.

    # Replace tbuehren with your DockerHub / Quay.io username.
    ORG="${2:-tbuehren}"

    source superhero-services-env.sh || return

    # Build Docker images containing the native executables.
    # We use Google Cloud Build for that but could also do it ourselves.
    for service in $SUPERHERO_SERVICES; do
        echo "======================================= BUILD $DOCKERFILE_TYPE IMAGE: $service ======================================= " && \

        cd $service  || return 1
        docker build -f src/main/docker/Dockerfile.$DOCKERFILE_TYPE -t $ORG/quarkus-workshop-$service . || return
        cd .. || return 1
    done
}

run "$1" || ( echo "An ERROR occured!"; false )
