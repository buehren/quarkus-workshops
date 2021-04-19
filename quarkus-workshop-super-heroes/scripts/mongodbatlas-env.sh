#!/bin/bash

function run
{
    # MongoDB Atlas

    # Create an API key for Terraform in the Mongo DB Cloud Project Access Manager (Permissions: Project Owner).
    # Add public and private keys to a file:
    #
    # mkdir -p ~/.config/mongodb
    # joe $HOME/.config/mongodb/key-terraform-PROJECTID.properties
    #
    # Content:
    # public_key="..."
    # private_key="..."
    #
    # chmod og-rwx $HOME/.config/mongodb/key-*


    if [ "$#" -ne 1 ]; then
        echo "Usage: mongodbatlas-env.sh mongodb_project_id"
        echo "Public and private keys must be available in $HOME/.config/mongodb/key-terraform-\$mongodb_project_id.properties"
        return 1
    fi

    mongodb_project_id="$1"
    echo "mongodb_project_id=$mongodb_project_id"

    mongodb_credentials_file="$HOME/.config/mongodb/key-terraform-$mongodb_project_id.properties"
    echo "mongodb_credentials_file=$mongodb_credentials_file"

    if [ ! -f "$mongodb_credentials_file" ]; then
        echo "Public and private keys must be available in $mongodb_credentials_file"
        return 201
    fi

    mongodb_public_key=$( grep -oP "(?<=^public_key=\").*(?=\")" "$mongodb_credentials_file" ) || return 202
    mongodb_private_key=$( grep -oP "(?<=^private_key=\").*(?=\")" "$mongodb_credentials_file" ) || return 203

    export ATLAS_PROJECT_ID="$mongodb_project_id"
    echo "ATLAS_PROJECT_ID=$ATLAS_PROJECT_ID"

    # environment variables for atlascli
    export ATLAS_PUBLIC_KEY="$mongodb_public_key"
    export ATLAS_PRIVATE_KEY="$mongodb_private_key"
    echo "ATLAS_PUBLIC_KEY=$ATLAS_PUBLIC_KEY"
    echo "ATLAS_PRIVATE_KEY=..."

    echo ""
}

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [[ $sourced == 1 ]]; then
    run "$@" || ( echo "An ERROR occured! $?"; false )
else
    echo "Please start this script with source ..."; false
fi
