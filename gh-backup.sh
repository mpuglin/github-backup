#!/bin/bash

# Set up variables
GITHUB_ORG="your-github-org"
GITHUB_TOKEN="your-github-token"
S3_BUCKET="your-s3-bucket"
BACKUP_DIR="/path/to/backup/dir"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Ensure AWS CLI is installed and configured
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install and configure it."
    exit 1
fi

# Ensure jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it."
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR" || exit

# Function to clone and compress repositories
backup_repos() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url" .git)
    
    # Clone the repository
    git clone --mirror "$repo_url"
    
    # Compress the repository
    tar -czf "${repo_name}_${TIMESTAMP}.tar.gz" "$repo_name.git"
    
    # Upload to S3
    aws s3 cp "${repo_name}_${TIMESTAMP}.tar.gz" "s3://${S3_BUCKET}/${repo_name}_${TIMESTAMP}.tar.gz"
    
    # Clean up local files
    rm -rf "$repo_name.git" "${repo_name}_${TIMESTAMP}.tar.gz"
}

# Get the list of all repositories in the organization with pagination
page=1
while : ; do
    repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$GITHUB_ORG/repos?per_page=100&page=$page" | jq -r '.[].clone_url')
    
    # Break the loop if no more repositories are returned
    if [ -z "$repos" ]; then
        break
    fi
    
    # Loop through each repository and back it up
    for repo in $repos; do
        echo "Backing up $repo"
        backup_repos "$repo"
    done
    
    ((page++))
done

echo "Backup completed successfully."

# Clean up
rm -rf "$BACKUP_DIR"
