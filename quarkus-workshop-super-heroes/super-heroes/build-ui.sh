#!/bin/bash

cd ui-super-heroes && \
echo "Building UI" && \
mvn install && \
npm install && \
./package.sh
