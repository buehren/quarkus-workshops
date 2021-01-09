#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and build the UI and JARs:
#     ./build-ui.sh
#     ./build-jars-all.sh
# ...and run the services in dev mode to create database records (required only once):
#     ./run-dev-all.sh
# ...and kill the services running in dev mode:
#     ./stop-dev-all.sh

echo "Starting Hero Service in background"
java -jar rest-hero/target/rest-hero-01-runner.jar &>> /tmp/rest-hero.jar.out &

echo "Starting Villain Service in background"
java -jar rest-villain/target/rest-villain-01-runner.jar &>> /tmp/rest-villain.jar.out &

echo "Starting Fight Service in background"
java -jar rest-fight/target/rest-fight-01-runner.jar &>> /tmp/rest-fight.jar.out &

echo "Starting Event-Statistics Service in background"
java -jar event-statistics/target/event-statistics-01-runner.jar &>> /tmp/event-statistics.jar.out &

echo "Starting UI in background"
java -jar ui-super-heroes/target/ui-super-heroes-01-runner.jar &>> /tmp/ui-super-heroes.jar.out &

echo ""
echo "Log outputs: tail -n 10 -F /tmp/*.jar.out"
echo ""

./show-urls.sh
