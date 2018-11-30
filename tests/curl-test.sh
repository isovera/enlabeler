#!/bin/bash

# This script prompts the user for several variables, such as GitHub
# username/password, and uses them to test the curl commands to add/remove/edit
# GitHub issue labels. May be useful for debugging.

# It can simply be run from the command line like a normal shell script, but
# in order to reuse the environment variables for individual curl commands, use 
# source ./test-curl.bash

read -p "Username: " USER
read -sp "Password: " PASS
echo
read -p "Repo: " REPO
read -p "Old label: " old_label
read -p "New label: " new_label
read -p "Description: " desc
read -p "Color: " color

export USER
export PASS
export REPO
export old_label
export new_label
export desc
export color

#data=$(jq -cr ".labels | .[] | select(.name==\"$label\")" < label-info.json)
data="{\"name\":\"$new_label\", \"description\":\"$desc\", \"color\":\"$color\"}"
export data

#label="${label//\"}"
#legacy=$(echo $data | jq -r ".legacy_names[]")
#data=$(echo $data | jq -c "{name, description, color}")
curl --user "$USER:$PASS" --include --request PATCH --data "$data" \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    "https://api.github.com/repos/$USER/$REPO/labels/$label"
#curl -v --user "$USER:$PASS" --include --request POST --data "$data" \
#    "https://api.github.com/repos/"$USER"/"$REPO"/labels"

