#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh

set -e

cd rest-hero
echo "Starting Hero Service in background"
mvn quarkus:dev -Ddebug=false &>> /tmp/rest-hero.dev.out &
cd ..

cd rest-villain
echo "Starting Villain Service in background"
mvn quarkus:dev -Ddebug=false &>> /tmp/rest-villain.dev.out &
cd ..

cd rest-fight
echo "Starting Fight Service in background"
mvn quarkus:dev -Ddebug=false &>> /tmp/rest-fight.dev.out &
cd ..

cd event-statistics
echo "Starting Event-Statistics Service in background"
mvn quarkus:dev -Ddebug=false &>> /tmp/event-statistics.dev.out &
cd ..

cd ui-super-heroes
echo "Building UI" && \
mvn install && \
npm install && \
./package.sh
echo "Starting UI in background (JAR - TODO: in dev mode, only localhost:8082 works but the ip address)" && \
java -jar ui-super-heroes/target/ui-super-heroes-01-runner.jar &>> /tmp/ui-super-heroes.jar.out &
#mvn quarkus:dev -Ddebug=false &>> /tmp/ui-super-heroes.dev.out &
cd ..

echo ""
echo "Log outputs: /tmp/*.dev.out /tmp/*.jar.out"
echo ""

./show-urls.sh
