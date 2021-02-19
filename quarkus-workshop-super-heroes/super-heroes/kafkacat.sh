#!/bin/bash

# Prints messages from Kafka topic "fights"

docker run --tty --rm -i --network host debezium/tooling:1.1 kafkacat -b localhost:9092 -C -o beginning -J -t fights
