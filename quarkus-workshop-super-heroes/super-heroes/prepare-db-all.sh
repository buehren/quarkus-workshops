#!/bin/bash

# Before this, start the infrastructure services:
#     ./run-infrastructure.sh
# ...and maybe clean all:
#     ./clean-all.sh
# ...and build the UI:
#     ./build-ui.sh
# ...and create database records (required only once):
#     QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION="drop-and-create" ./run-dev-all.sh

# You should STOP "vagrant rsync-auto" while running this to avoid deletion of
#   rest-fight/src/main/resources/META-INF/resources/super-heroes
# when changing files on the host!

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do

        echo "======================================= CREATE DB: $service ======================================= "

        # Service name used in environment variables (upcase and "_"   instead of "-")
        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        var_datasource_dbname=SERVICE_${SERVICE}_DATASOURCE_DBNAME
        var_datasource_user=SERVICE_${SERVICE}_DATASOURCE_USER
        var_datasource_pwd=SERVICE_${SERVICE}_DATASOURCE_PWD

        if [ "${!var_datasource_dbname}" != "" ]; then
            cat "$service"/src/main/resources/{create.sql,import.sql} | PGPASSWORD="${!var_datasource_pwd}" psql -h localhost -U "${!var_datasource_user}" -d "${!var_datasource_dbname}" || return
        fi
    done
}

run "$@" || ( echo "An ERROR occured!"; false )
