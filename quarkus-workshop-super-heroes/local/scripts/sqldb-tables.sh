#!/bin/bash

# Before this, start the infrastructure services:
#     ./start-infrastructure.sh
# ...and create the databases (unless they were already created by Terraform):
#     ./sqldb-databases.sh

function run
{
    source superhero-services-env.sh || return

    for service in $SUPERHERO_SERVICES; do

        echo "======================================= CREATE/IMPORT TABLES: $service ======================================= "

        # Service name used in environment variables (upcase and "_"   instead of "-")
        SERVICE=${service^^}
        SERVICE=${SERVICE//-/_}

        # Service name without "rest-..."
        service_new=${service}
        service_new=${service_new#rest-}
        service_new=${service_new#event-}

        var_SQLDB_PASSWORD=SERVICE_${SERVICE}_SQLDB_PASSWORD

        if [ "${!var_SQLDB_PASSWORD}" != "" ]; then
            cat "$service"/deployment/sqldb/{create.sql,import.sql} \
                | PGPASSWORD="${!var_SQLDB_PASSWORD}" \
                     psql "postgres://service_${service_new}@localhost/${service_new}_db?options=--search_path%3D${service_new}" \
            || return
        fi
    done
}

run "$@" || ( echo "An ERROR occured! $?"; false )
