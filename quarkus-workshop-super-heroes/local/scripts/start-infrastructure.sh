#!/bin/bash
cd infrastructure && \
docker-compose -f docker-compose.yaml up -d zookeeper && \
sleep 10 && # wait until zookeeper is hopefully running so that kafka can connect to it (there must be a better way...) \
docker-compose -f docker-compose.yaml up -d && \
cd .. && \
sleep 15 # wait until postgres and kafka are hopefully running (there must be a better way...)
