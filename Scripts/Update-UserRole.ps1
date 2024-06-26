function Update-UserRole {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CsvFilePath,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    # Connect to Azure
    
    $csvData = Import-Csv -Path $CsvFilePath
    # Get all contributors to the subscription

    # Remove their role and assign them the reader role
    foreach ($row in $csvData) {
        $userUPN = $row.UPN + "@" + "cognizant.com"
        $user = Get-AzADUser -UserPrincipalName $userUPN
        # Assign the user to the Contributor role in the specified Azure subscription
        $user | Remove-AzRoleAssignment -RoleDefinitionName "Reader" -Scope "/subscriptions/$SubscriptionId"
        $user | New-AzRoleAssignment -RoleDefinitionName "Contributor" -Scope "/subscriptions/$SubscriptionId"
    }

    Write-Host "All contributors have been updated to the reader role."
}