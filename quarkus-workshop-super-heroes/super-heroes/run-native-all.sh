#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./run-dev-all.sh
# ...and kill the services running in dev mode:
#     ./stop-dev-all.sh
# ...and build the UI and native executables:
#     ./build-ui.sh
#     ./build-native-all.sh

echo "Starting Hero Service in background"
rest-hero/target/rest-hero-01-runner &>> /tmp/rest-hero.native.out &

echo "Starting Villain Service in background"
rest-villain/target/rest-villain-01-runner &>> /tmp/rest-villain.native.out &

echo "Starting Fight Service in background"
rest-fight/target/rest-fight-01-runner &>> /tmp/rest-fight.native.out &

echo "Starting Event-Statistics Service in background"
event-statistics/target/event-statistics-01-runner &>> /tmp/event-statistics.native.out &

# HTML UI is available in the fight service
#echo "Starting UI in background"
#java -jar ui-super-heroes/target/ui-super-heroes-01-runner.jar &>> /tmp/ui-super-heroes.jar.out &

echo ""
echo "Log outputs: tail -n 10 -F /tmp/*.native.out"
echo ""

./show-urls.sh
