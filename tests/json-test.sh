#!/bin/bash

jq -c -r ".labels | .[]" < label-info.json | while read line; do
    echo "Accept: application/vnd.github.symmetra-preview+json" --user \
    "$USER:$PASS" --include --request POST --data "$line" \
    "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
done
