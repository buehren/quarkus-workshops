#!/bin/bash
cd infrastructure && \
docker-compose -f docker-compose-linux.yaml stop && \
cd ..
