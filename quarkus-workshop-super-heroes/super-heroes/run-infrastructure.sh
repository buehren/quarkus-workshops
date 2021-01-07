#!/bin/bash
cd infrastructure && \
docker-compose -f docker-compose-linux.yaml up -d && \
cd .. && \
sleep 15
