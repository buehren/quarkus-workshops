#!/bin/bash
cd infrastructure && \
docker-compose -f docker-compose.yaml stop && \
cd ..
