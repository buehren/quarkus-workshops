#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

docker-compose stop

pkill -e -f ".*target/.*runner.*"
