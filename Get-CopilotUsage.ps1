# Script to fetch GitHub Copilot usage data for enterprise, organization, and teams.

# Define the GitHub API base URL
$GitHubApiBaseUrl = "https://api.github.com"

# Define the bearer token (replace with your actual token)
$BearerToken = "your_bearer_token_here"

# Function to make an API request
function Invoke-GitHubApi {
    param (
        [string]$Endpoint
    )
    $Headers = @{
        Authorization = "Bearer $BearerToken"
        Accept        = "application/vnd.github+json"
        User-Agent    = "PowerShell-Script"
    }
    Invoke-RestMethod -Uri "$GitHubApiBaseUrl/$Endpoint" -Headers $Headers -Method Get
}

# Fetch enterprise Copilot usage
function Get-EnterpriseCopilotUsage {
    param (
        [string]$EnterpriseSlug
    )
    Write-Host "Fetching enterprise Copilot usage for: $EnterpriseSlug"
    Invoke-GitHubApi -Endpoint "enterprises/$EnterpriseSlug/copilot/usage"
}

# Fetch organization Copilot usage
function Get-OrganizationCopilotUsage {
    param (
        [string]$OrgName
    )
    Write-Host "Fetching organization Copilot usage for: $OrgName"
    Invoke-GitHubApi -Endpoint "orgs/$OrgName/copilot/usage"
}

# Fetch multiple teams' Copilot usage
function Get-TeamsCopilotUsage {
    param (
        [string[]]$Teams
    )
    foreach ($Team in $Teams) {
        if ($Team -match "^([^/]+)/([^/]+)$") {
            $OrgName = $Matches[1]
            $TeamSlug = $Matches[2]
            Write-Host "Fetching team Copilot usage for: $OrgName/$TeamSlug"
            Invoke-GitHubApi -Endpoint "orgs/$OrgName/teams/$TeamSlug/copilot/usage"
        } else {
            Write-Host "Invalid team format: $Team. Use 'orgname/teamname'."
        }
    }
}

# Example usage
# Replace these placeholders with actual values
$EnterpriseSlug = "your_enterprise_slug"
$OrgName = "your_org_name"
$Teams = @("org1/team1", "org2/team2") # Example format for multiple teams

# Fetch and display usage data
$EnterpriseUsage = Get-EnterpriseCopilotUsage -EnterpriseSlug $EnterpriseSlug
Write-Output "Enterprise Usage: $($EnterpriseUsage | ConvertTo-Json -Depth 10)"

$OrgUsage = Get-OrganizationCopilotUsage -OrgName $OrgName
Write-Output "Organization Usage: $($OrgUsage | ConvertTo-Json -Depth 10)"

foreach ($Team in $Teams) {
    $TeamUsage = Get-TeamsCopilotUsage -Teams @($Team)
    Write-Output "Team Usage: $($TeamUsage | ConvertTo-Json -Depth 10)"
}
