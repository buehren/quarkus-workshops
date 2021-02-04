#!/bin/bash

function run
{
    title="$1"
    mvn_phases="$2"
    mvn_params="$3"

    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
        echo "======================================= $title: $service ======================================= " && \
        if [ "$service" == "rest-fight" ]; then
            cp -Rvp ui-super-heroes/dist/* rest-fight/src/main/resources/META-INF/resources || {
                echo "UI not found: Run ./build-ui.sh"
                return 1;
            }
        fi

        cd $service  || return 1
        mvn $mvn_phases $mvn_params || return 1
        cd ..  || return 1

        if [ "$service" == "rest-fight" ]; then
            ls -d rest-fight/src/main/resources/META-INF/resources/super-heroes || {
                echo "UI no longer found after build: Maybe it was deleted by rsync?"
                return 1;
            }
        fi
    done
}

run || ( echo "An ERROR occured!"; false )
