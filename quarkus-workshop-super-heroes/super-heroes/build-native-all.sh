#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
      echo "======================================= $service ======================================= " && \
      [ "$service" == "rest-fight" ] && ( cp -R ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
          echo "UI not found: Run ./build-ui.sh"
          return 1;
      })
      \
      cd $service && \
      mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS  && \
      cd .. && \
      \
      [ "$service" == "rest-fight" ] && ( ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
          echo "UI no longer found after build: Maybe it was deleted by rsync?"
          return 1;
      })
    done
}

run || ( echo "An ERROR occured!"; false )
