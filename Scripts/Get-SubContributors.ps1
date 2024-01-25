# Purpose: Get all contributors for a subscription and export to CSV
# Usage: Get-AzureSubscriptionContributors -SubscriptionId "subID" -OutputPath "C:\Users\jason\Documents" -OutputFileName "contributors.csv"
# This was created by GitHub Copilot
# the goal was to get signin name and display name.  To use for an internal mass BCC email project.  Signin Name would resolve to email address.

function Get-AzureSubscriptionContributors {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputFileName
    )
    
    $contributors = Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Where-Object { $_.RoleDefinitionName -eq "Contributor" -and $_.ObjectType -eq "User" }
    $upns = $contributors | ForEach-Object { 
        [PSCustomObject]@{
            SignInName = $_.SignInName
            DisplayName = $_.DisplayName
        }
    }

    $upns | Export-Csv -Path "$OutputPath\$OutputFileName" -NoTypeInformation
}
