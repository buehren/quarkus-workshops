#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh
# ...and when starting this script with parameter "jvm":
#     ./build-jars-all.sh
# ...and when starting script with parameter "native":
#     ./build-native-all.sh


# Usage: build-docker-all.sh {DOCKERFILE_TYPE} {ORG}
#
# DOCKERFILE_TYPE (optional):
#
#   native
#       Compile binary executable and create Docker image (default)
#   native-nopackage
#       Create Docker image from binary executable (run build-native-all.sh before)
#   jvm
#       Create Docker Image from JARs (run build-jars-all.sh before)
#
# ORG (optional):
#       your DockerHub / Quay.io username


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
        if [ "$service" == "rest-fight" ]; then
            mkdir -p rest-fight/src/main/resources/META-INF/resources || return
            cp -Rvp ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
                echo "UI not found: Run ./build-ui.sh"
                return 1;
            }
        fi

        cd $service  || return 1
        docker build -f src/main/docker/Dockerfile.$DOCKERFILE_TYPE -t $ORG/quarkus-workshop-$service . || return
        cd .. || return 1

        if [ "$service" == "rest-fight" ]; then
            ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
                echo "UI no longer found after build: Maybe it was deleted by rsync?"
                return 1;
            }
        fi
    done
}

run "$1" || ( echo "An ERROR occured!"; false )
