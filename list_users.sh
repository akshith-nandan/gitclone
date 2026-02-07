#!/bin/bash

# ------------------------------------
# Project : GitHub Repository Access Audit (With Pagination)
# ------------------------------------

API_URL="https://api.github.com"

# GitHub credentials (export as env vars)
USERNAME=$GITHUB_USERNAME
TOKEN=$GITHUB_TOKEN

# Validate arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Validate credentials
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: Set GITHUB_USERNAME and GITHUB_TOKEN"
    exit 1
fi

REPO_OWNER=$1
REPO_NAME=$2

# GitHub API GET request
github_api_get() {
    local endpoint=$1
    curl -s -u "$USERNAME:$TOKEN" "$API_URL/$endpoint"
}

# List users with READ access (pagination supported)
list_read_users() {
    local page=1
    local found=false

    echo "Users with READ access:"

    while true; do
        endpoint="repos/$REPO_OWNER/$REPO_NAME/collaborators?page=$page&per_page=100"

        response=$(github_api_get "$endpoint")

        users=$(echo "$response" | jq -r \
            '.[] | select(.permissions.pull == true) | .login')

        # If no users returned → stop pagination
        if [ -z "$users" ]; then
            break
        fi

        echo "$users"
        found=true
        ((page++))
    done

    if [ "$found" = false ]; then
        echo "No users with read access found."
    fi
}

echo "Auditing access for repository: $REPO_OWNER/$REPO_NAME"
list_read_users
