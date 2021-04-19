#!/bin/bash

# Before this, build the UI:
#     ./build-ui.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    source gcp-env.sh || return
    source gcp-sql-env.sh || return
    source kafka-env.sh || return

    source gcp-sql-env-sqlproxy || return

    ./start-dev.sh || return
}

run || ( echo "An ERROR occured! $?"; false )
