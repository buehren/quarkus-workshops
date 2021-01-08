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

echo "Starting UI in background (JAR - TODO: port 8080 missing in native fight service)" && \
java -jar ui-super-heroes/target/ui-super-heroes-01-runner.jar &>> /tmp/ui-super-heroes.jar.out &

echo ""
echo "Log outputs: tail -n 10 -F /tmp/*.jar.out  +  docker-compose logs -f"
echo ""

./show-urls.sh
