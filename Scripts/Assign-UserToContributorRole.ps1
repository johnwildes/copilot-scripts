function Add-UserToContributorRole {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CsvFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )
    
    # Read the CSV file
    $csvData = Import-Csv -Path $CsvFilePath
    
    # Iterate through each row in the CSV
    foreach ($row in $csvData) {
        $userUPN = $row.UPN + "@" + "cognizant.com"
        $user = Get-AzADUser -UserPrincipalName $userUPN
        # Assign the user to the Contributor role in the specified Azure subscription
        New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionName "Contributor" -Scope "/subscriptions/$SubscriptionId"
        
        Write-Host "Assigned user '$userUPN' to the Contributor role in subscription '$SubscriptionId'"
    }
}