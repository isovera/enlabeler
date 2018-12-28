#!/bin/bash

# USE: initialize github workflows
#
# Updates label colors, adds new defaults, and deletes obsolete labels
# 	-uses data from label-info.json file
#
# BEFORE RUNNING:
#	Have GitHub login credentials ready

function git_to_zen(){
    echo Transfer GitHub labels into ZenHub.
    # Iterate through issues
    movetoclose=("4 - Dev queue" "5 - Dev" "6 - Test queue" "7 - Test QA" "8 - Live queue" "9 - Live QA")
    for num in ${issue_nums[@]}; do
        echo "Issue num is $num"
        tagged=( $(curl --user $USER:$PASS "https://api.github.com/repos/$REPO_USER/$REPO_NAME/issues/$num/labels" | jq .[].name) )
#        tagged="${tagged// /%20}"
#        tagged="${tagged//\"}"
#        # Iterate through labels tagged for each issue
#        for label in ${tagged[@]}
#        do
#            label="${label/"%20"/}"
#            label="${label//%20/ }"
#            echo $label
#            # Move issues tagged w/ old Github progress labels to Zenhub pipelines
#            if [ "$label" = "0 - Backlog" ]; then
#                curl -H "X-Authentication-Token: $TOKEN" --data "pipeline_id=$backlog_ID&position=$pos" \
#                     https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/moves
#            elif [ "$label" = "1 - Slated" ]; then
#                curl -H "X-Authentication-Token: $TOKEN" --data "pipeline_id=$slated_ID&position=$pos" \
#                     https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/moves
#            elif [ "$label" = "2 - Code" ]; then
#                curl -H "X-Authentication-Token: $TOKEN" --data "pipeline_id=$in_progress_ID&position=$pos" \
#                     https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/moves
#            elif [ "$label" = "3A - Feature QA" ]; then
#                curl -H "X-Authentication-Token: $TOKEN" --data "pipeline_id=$feature_QA_ID&position=$pos" \
#                     https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/moves
#            elif [ "$label" = "3B - Code Review" ]; then
#                curl -H "X-Authentication-Token: $TOKEN" --data "pipeline_id=$code_review_ID&position=$pos" \
#                     https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/moves
#            elif [[ " ${movetoclose[@]} " =~ " ${label} " ]]; then
#                curl --user "$USER:$PASS" --include --request PATCH --data '{"state":"closed"}' \
#                     https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/issues/"$num"
#            # Map Github estimate labels to Zenhub estimates
#            elif [[ $label = *"E."* ]]; then
#                temp=${label#*=}
#                temp=${temp#*.}
#                est=${temp%" h"*}
#                # Set the estimate in Zenhub
#                curl -X PUT https://api.zenhub.io/p1/repositories/"$repo_ID"/issues/"$num"/estimate \
#                -H 'content-type: application/json' -H "x-authentication-token: $TOKEN" -d '{"estimate":'$est'}'
#            fi
#        done
    done
}

function jsonValue(){
	KEY=$1
	num=$2
	awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | sed -n ${num}p
}

function update_and_delete(){
    old_labels="${old_labels// /%20}"
    for label in ${old_labels[@]}
    do
        master_label_data=${master_label_data[@]#*'"url": "'}
		# Format the label names
        label="${label/'%20'/}"
        if [ ! "${label: -1}" = '"' ]; then
			manage_json_error $label
		fi
		#label=$(echo "$label" | tr '[:upper:]' '[:lower:]')
        label=$(echo $label | sed 's/%20/\ /')
        # Search by 'name' value instead of using `grep`
        data=$(jq -cr ".labels[] | select(.legacy_names[]? | .==$label) | del(.legacy_names?)" < label-info.json)
        label=$(echo $label | sed 's/\ /%20/')
        if [[ $data ]]; then
            label="${label//\"}"
            newLabel=$(echo $data | jq -r ".name")
            echo "Renaming $label to $newLabel..."
            curl --user "$USER:$PASS" --include --request PATCH --data "$data" \
                -H "Accept: application/vnd.github.symmetra-preview+json" \
                "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels/$label"
        elif [[ $ANSWER = *Y* ]]; then
            label="${label//\"}"
            echo "Deleting label: $label"
            curl --user "$USER:$PASS" --include --request DELETE "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels/$label"
        fi
   done
}

function add_defaults(){
    # Iterate through all labels in JSON file except those renamed from legacy labels
    jq -c '.labels[] | select(has("legacy_names") | not)' < label-info.json | while read line
    do
        echo "Creating new label: $line..."
        curl -H "Accept: application/vnd.github.symmetra-preview+json" --user "$USER:$PASS" --include --request POST --data "$line" \
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
	old_labels=$(curl --user "$USER:$PASS" "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels" | jsonValue name)
	master_label_data=$(curl --user "$USER:$PASS" "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels")

	# Get the GitHub repository ID
	repo_ID=$(curl https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME" | jsonValue id)
	repo_ID=${repo_ID:0:10} # Grab the repo ID number

	# Get range of issue nums
	issue_nums=$(curl https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME/issues" | jsonValue number)
	max_issue=${issue_nums:0:2} # Grab the latest (i.e highest) active issue number

	#Grab the pipeline IDs
	temp=${repo_data%'","name":"Backlog"'*}
	backlog_ID=${temp: -24} # Grab the pipeline number (assumes 24 digits)

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
ZENHUB=false
while getopts 'z' opt; do
    case $opt in
      z) ZENHUB=true
         ;;
     \?) echo "Usage: ${0##*/} [-z]" >&2
         exit 2
         ;;
    esac
done

echo "Welcome to Enlabeler!
	Credentials required:
		• Github username/password"
if $ZENHUB; then
    echo "		• Zenhub access token (obtainable from https://app.zenhub.com/dashboard/tokens)

	PLEASE (!) ensure you have created the necessary ZenHub pipelines"
fi
echo

read -p "GitHub User: " USER

# Generate a personal access token at https://github.com/settings/tokens
read -sp "GitHub Password (or token if using 2fa): " PASS
echo

# Get repo / user info
read -p "GitHub Repo (expected format is 'owner/repository' e.g. 'isovera/enlabeler'): " REPO

# Get ZenHub info
if $ZENHUB; then
    read -sp "ZenHub Token (find at https://app.zenhub.com/dashboard/tokens): " TOKEN
    echo
    read -p "Label Pipelines file (default: labels-pipelines.json): " PIPELINES
    if [ -z $PIPELINES ]; then
        PIPELINES="labels-pipelines.json"
    fi
    if [ -e $PIPELINES ] && [ -r $PIPELINES ]; then
        echo Reading $PIPELINES...
    else
        echo "Could not open $PIPELINES" >&2
        exit 3
    fi
fi

REPO_USER=$(echo "$REPO" | cut -f1 -d /)
REPO_NAME=$(echo "$REPO" | cut -f2 -d /)

read -p 'Would you like to delete obsolete labels? (Y/N): ' ANSWER
get_data
if [[ $ZENHUB ]]; then
    git_to_zen
fi
if [[ $ANSWER =~ ^[Nn][Oo]?$ ]]; then
    echo 'Running without deleting old labels'
    update_and_delete
else
    update_and_delete
fi
add_defaults

