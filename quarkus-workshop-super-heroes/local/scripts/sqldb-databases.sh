#!/bin/bash

# Before this, start the infrastructure services:
#     ./start-infrastructure.sh

function run
{
    echo "======================================= CREATE DATABASES: $service ======================================= "
    psql "postgres://postgres@localhost/postgres" -f infrastructure/db-init/initialize-databases.sql
}

run "$@" || ( echo "An ERROR occured! $?"; false )
