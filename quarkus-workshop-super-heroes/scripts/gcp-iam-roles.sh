#!/bin/bash

function run
{
    if [ "$#" -lt 3 ]; then
        echo "Usage: gcp-iam-roles.sh project_id account_email role [role...]"
        echo "       - you must be logged in with gcloud auth login when service account needs to be created"
        return 1
    fi

    project_id="$1"
    account_email="$2"
    shift 2
    roles=( "$@" )

    echo "project_id=$project_id"
    echo "account_email=$account_email"
    echo "roles=${roles[*]}"

    roles_exist=($( \
        gcloud projects get-iam-policy \
            --flatten=bindings[].members \
            --format="table[no-heading](bindings.role)" \
            --filter="bindings.members:$account_email" \
            "$project_id" \
    )) || return
    echo "roles_exist=${roles_exist[*]}"

    for role in "${roles[@]}"; do
        if [[ ! " ${roles_exist[@]} " =~ " ${role} " ]]; then
            gcloud \
                projects add-iam-policy-binding \
                "$project_id" \
                --member="serviceAccount:$account_email" \
                --role="$role" \
                || return
        fi
    done

}

run "$@" || ( echo "An ERROR occured! $?"; false )
