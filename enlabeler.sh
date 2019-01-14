#!/bin/bash

# USE: initialize github workflows
#
# Updates label colors, adds new defaults, and deletes obsolete labels
# 	-uses data from label-info.json file
#
# BEFORE RUNNING:
#	Have GitHub login credentials ready

function update_and_delete(){
	old_labels="${old_labels// /%20}"
    jq -nc "$master_label_data | .[]" | while IFS=$'\n' read oldLabel; do
		name=$(jq -n "$oldLabel | .name")
		url=$(jq -rn "$oldLabel | .url")
        # Search by 'name' value instead of using `grep`
        data=$(jq -nc "$legacy_labels | .[] | select(.legacy_names==$name) | del(.legacy_names)")
        if [[ $data ]]; then
            echo "Renaming $name to $(jq -n "$data | .name")"
            curl --user "$USER:$PASS" --include --request PATCH --data "$data" \
                -H "Accept: application/vnd.github.symmetra-preview+json" $url
        elif [[ $ANSWER = *Y* ]]; then
            echo "Deleting label: $name"
            curl --user "$USER:$PASS" --include --request DELETE $url
        fi
   done
}

function add_defaults(){
    # Iterate through all labels in JSON file except those renamed from legacy labels
    jq -nc "$default_labels | .[]" | while IFS=$'\n' read new_label; do
        echo "Creating new label: $(jq -n "$new_label | .name")"
        curl -H "Accept: application/vnd.github.symmetra-preview+json" --user "$USER:$PASS" --include --request POST --data "$new_label" \
             "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
    done
}

# Manage json error caused by label names with colons
function manage_json_error(){
	word=$1
	temp=${master_label_data[@]#*'labels/'}
	temp=${temp[@]:0:60}
	temp=${temp[@]%'", "name'*}
		if [ ! " $temp " = " $word " ]; then
            a='"'
            temp=$a$temp$a
			label=$temp
		fi
}

function get_data(){
	# Get current labels from GitHub API
	master_label_data=$(curl --user "$USER:$PASS" "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels")

	# Get the GitHub repository ID
	repo_ID=$(curl --user "$USER:$PASS" https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME" | jq .id)
	repo_ID=${repo_ID:0:10} # Grab the repo ID number

	# Get range of issue nums
	issue_nums=$(curl --user "$USER:$PASS" https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME/issues" | jq length)
	max_issue=${issue_nums:0:2} # Grab the latest (i.e highest) active issue number

	#Grab the pipeline IDs
	temp=${repo_data%'","name":"Backlog"'*}
	backlog_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

	# Get new label data from JSON file
	default_labels=$(jq "[.labels[] | select(has(\"legacy_names\") | not)]" label-info.json)
	legacy_labels=$(jq "[.labels[] | select(has(\"legacy_names\")) | .legacy_names = .legacy_names[]]" label-info.json)

	temp=${repo_data%'","name":"Slated"'*}
	slated_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

	temp=${repo_data%'","name":"In Progress"'*}
	in_progress_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

	temp=${repo_data%'","name":"Feature QA"'*}
	feature_QA_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

	temp=${repo_data%'","name":"Code Review"'*}
	code_review_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

	# Set pipeline position
	pos="top"
}

#***************************** Terminal Interface **************************
echo "Welcome to Enlabeler!
Credentials required: Github username/password"

echo -n "GitHub User: "
read USER

# Generate a personal access token at https://github.com/settings/tokens
echo -n "GitHub Password (or token if using 2fa): "
read -s PASS
echo

# Get repo / user info
echo -n "GitHub Repo (expected format is 'owner/repository' e.g. 'isovera/enlabeler'): "
read REPO

REPO_USER=$(echo "$REPO" | cut -f1 -d /)
REPO_NAME=$(echo "$REPO" | cut -f2 -d /)

read -e -p 'Would you like to delete obsolete labels? (Y/N):' ANSWER
    get_data
    if [[ $ANSWER =~ ^[Nn]$ ]]; then
		echo 'Running without deleting old labels'
        update_and_delete
	else
        update_and_delete
	fi
add_defaults

