#!/bin/bash

# Before this, build the UI and native executables:
#     ./build-ui.sh
#     ./build-native-all.sh


# Replace ORG with your DockerHub / Quay.io username.
export ORG=tbuehren

cd rest-hero && \
docker build -f src/main/docker/Dockerfile.native -t $ORG/quarkus-workshop-hero . && \
cd .. && \
cd rest-villain && \
docker build -f src/main/docker/Dockerfile.native -t $ORG/quarkus-workshop-villain . && \
cd .. && \
cd rest-fight && \
docker build -f src/main/docker/Dockerfile.native -t $ORG/quarkus-workshop-fight . && \
cd .. && \
cd event-statistics && \
docker build -f src/main/docker/Dockerfile.native -t $ORG/quarkus-workshop-stats . && \
cd ..
