#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

pkill    -e -f ".*target/.*runner.*"
sleep 2
pkill -9 -e -f ".*target/.*runner.*"
