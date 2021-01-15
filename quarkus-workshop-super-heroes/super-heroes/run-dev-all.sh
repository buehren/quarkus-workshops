#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

set -e

cd rest-hero
mvn clean compile $MAVEN_EXTRA_ARGS
echo "Starting Hero Service in background"
mvn quarkus:dev -Ddebug=false $MAVEN_EXTRA_ARGS &>> /tmp/rest-hero.dev.out &
cd ..

cd rest-villain
mvn clean compile $MAVEN_EXTRA_ARGS
echo "Starting Villain Service in background"
mvn quarkus:dev -Ddebug=false $MAVEN_EXTRA_ARGS &>> /tmp/rest-villain.dev.out &
cd ..

cd ui-super-heroes
mvn clean compile $MAVEN_EXTRA_ARGS
echo "Starting UI in background (not really necessary because UI is available in rest-fight service)"
mvn quarkus:dev -Ddebug=false $MAVEN_EXTRA_ARGS &>> /tmp/ui-super-heroes.dev.out &
cd ..

cd rest-fight
cp -R ../ui-super-heroes/dist/* src/main/resources/META-INF/resources
mvn clean compile $MAVEN_EXTRA_ARGS
echo "Starting Fight Service in background"
mvn quarkus:dev -Ddebug=false $MAVEN_EXTRA_ARGS &>> /tmp/rest-fight.dev.out &
ls -d src/main/resources/META-INF/resources/super-heroes
cd ..

cd event-statistics
mvn clean compile $MAVEN_EXTRA_ARGS
echo "Starting Event-Statistics Service in background"
mvn quarkus:dev -Ddebug=false $MAVEN_EXTRA_ARGS &>> /tmp/event-statistics.dev.out &
cd ..

echo ""
echo "Log outputs: tail -n 10 -F /tmp/*.dev.out"
echo ""

./show-urls.sh
