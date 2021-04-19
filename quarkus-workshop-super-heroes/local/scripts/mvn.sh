#!/bin/bash

function run
{
    if [ "$#" -ne 3 ]; then
        echo "Usage: mvn.sh title mvn_phases mvn_params"
    fi

    title="$1"
    mvn_phases="$2"
    mvn_params="$3"

    echo title="$title"
    echo mvn_phases="$mvn_phases"
    echo mvn_params="$mvn_params"

    source services-env.sh || return

    for service in $SUPERHERO_SERVICES; do
        echo "======================================= $title: $service ======================================= " && \
        if [ "$service" == "rest-fight" ]; then
            mkdir -p rest-fight/src/main/resources/META-INF/resources || return
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

run "$@" || ( echo "An ERROR occured! $?"; false )
