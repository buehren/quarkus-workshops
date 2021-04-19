#!/usr/bin/env bash

function run
{
    # tag::adocShell[]
    ./node_modules/.bin/ng build --prod --base-href "." || return

    export DEST=src/main/resources/META-INF/resources
    rm -Rf ${DEST}  || return
    mkdir -p ${DEST} || return
    cp -R dist/* ${DEST} || return
    # end::adocShell[]
}

run "$1" || ( echo "An ERROR occured! $?"; false )
