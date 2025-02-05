# Purpose: Get all contributors for a subscription and export to CSV
# Usage: Get-AzureSubscriptionContributors -SubscriptionId "subID" -OutputPath "C:\Users\jason\Documents" -OutputFileName "contributors.csv"
# This was created by GitHub Copilot
# the goal was to get signin name and display name.  To use for an internal mass BCC email project.  Signin Name would resolve to email address.

function Get-AzureSubscriptionContributorsAndOwners {
    param (
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputFileName
    )
    
    $subscriptions = Get-AzSubscription
    $allContributorsAndOwners = @()

    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.Id
        $contributors = Get-AzRoleAssignment -Scope "/subscriptions/$subscriptionId" | Where-Object { ($_.RoleDefinitionName -eq "Contributor" -or $_.RoleDefinitionName -eq "Owner") -and $_.ObjectType -eq "User" }
        $upns = $contributors | ForEach-Object { 
            [PSCustomObject]@{
                SubscriptionId = $subscriptionId
                SubscriptionName = $subscription.Name
                SignInName = $_.SignInName
                DisplayName = $_.DisplayName
                Role = $_.RoleDefinitionName
            }
        }
        $allContributorsAndOwners += $upns
    }

    $allContributorsAndOwners | Export-Csv -Path "$OutputPath\$OutputFileName" -NoTypeInformation
}
