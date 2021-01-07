#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

pkill -e -f ".*super-heroes/.*/target/.*\.jar.*"
