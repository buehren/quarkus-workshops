#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./run-dev-all.sh
# ...and kill the services running in dev mode
# ...and build the native executables:
#     ./build-native-all.sh
# ...and build the Docker images:
#     ./build-docker-all.sh

echo "Starting Services in background"
docker-compose up -d

echo ""
echo "Log outputs: docker-compose logs -f"
echo ""

./show-urls.sh
