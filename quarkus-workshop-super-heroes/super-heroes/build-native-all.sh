#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

cd rest-hero && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS && \
cd .. && \
cd rest-villain && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS  && \
cd .. && \
cd rest-fight && \
cp -R ../ui-super-heroes/dist/* src/main/resources/META-INF/resources && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS  && \
ls -d src/main/resources/META-INF/resources/super-heroes && \
cd .. && \
cd event-statistics && \
mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS  && \
cd ..
