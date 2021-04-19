#!/bin/bash

# Before this, start the infrastructure services:
#     ./start-infrastructure.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./start-dev.sh
# ...and kill the services running in dev mode:
#     ./stop-dev.sh
# ...and build the UI and native executables:
#     ./build-ui.sh
#     ./build-native.sh
# ...and build the Docker images:
#     ./build-docker.sh

echo "Starting Services in background"
docker-compose up -d $SUPERHERO_SERVICES

echo ""
echo "Log outputs: docker-compose logs -f"
echo ""

./show-urls.sh
