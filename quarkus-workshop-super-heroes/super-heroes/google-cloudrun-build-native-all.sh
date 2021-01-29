#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this
# to avoid deletion of file in the guest VM when changing files on the host!

function run
{
    source superhero-services-env.sh || return
    source google-cloudrun-env.sh || return
    source google-cloudsql-env.sh || return

    for service in $SUPERHERO_SERVICES; do
      echo "======================================= BUILD NATIVE: $service ======================================= " && \
      [ "$service" == "rest-fight" ] && ( cp -R ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
          echo "UI not found: Run ./build-ui.sh"
          return 1;
      })

      source google-cloudsql-datasource-env.sh $service  || return 1

      cd $service  || return 1
      mvn clean package -Pnative -Dnative-image.docker-build=true -DskipTests $MAVEN_EXTRA_ARGS   || return 1
      cd ..  || return 1

      [ "$service" == "rest-fight" ] && ( ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
          echo "UI no longer found after build: Maybe it was deleted by rsync?"
          return 1;
      })
    done
}

run || ( echo "An ERROR occured!"; false )
