# github-backup
shell script to backup repositories for an organization

## Explanation:
### Pagination Loop: 
The script uses a while loop to fetch repositories page by page. The page variable is used to track the current page number.

### API Request with Pagination: 
The API request includes the page parameter to fetch repositories from the current page. The per_page parameter is set to 100 to fetch up to 100 repositories per page.

### Breaking the Loop: If no more repositories are returned (i.e., the response is empty), the loop breaks.

### Processing Repositories: 
For each repository URL returned, the script calls the backup_repos function to clone, compress, and upload the repository to the S3 bucket.

### Increment Page Number: 
After processing the repositories on the current page, the page variable is incremented to fetch the next set of repositories.

## Requirements:
### jq: 
Ensure jq is installed for parsing JSON responses. Install it using brew install jq on macOS, sudo apt-get install jq on Ubuntu, or equivalent for other systems.

### AWS CLI: 
Ensure the AWS CLI is installed and configured with appropriate permissions to write to the S3 bucket. Install it from the AWS CLI official documentation.

### Note:
Be cautious with the handling of sensitive information such as your GitHub token. Ensure it is stored securely and not hard-coded in production scripts. Use environment variables or secure vaults if possible.
Test the script with a smaller set of repositories first to ensure it works as expected before running it on the entire organization.
