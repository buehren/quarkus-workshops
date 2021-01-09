#!/bin/bash

# To also stop the infrastructure services:
#     ./stop-infrastructure.sh

pkill -ef "java -jar .*/target/.*-runner\.jar.*"
