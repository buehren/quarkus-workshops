#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    source google-cloudrun-env.sh || return
    source google-cloudsql-env.sh || return
    source kafka-env.sh || return

    source google-cloudsql-local-env.sh || return

    ./run-dev-all.sh || return
}

run || ( echo "An ERROR occured!"; false )
