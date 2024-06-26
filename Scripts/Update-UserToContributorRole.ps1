function Update-UserToContributorRole {
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
        $roleAssignment = Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" -PrincipalId "675bdadb-4451-4c6f-b79a-906ee77b059f"
        # Update the user's current role to Contributor in the specified Azure subscription
        Set-AzRoleAssignment -InputObject $roleAssignment -PassThru
        
        Write-Host "Assigned user '$userUPN' to the Contributor role in subscription '$SubscriptionId'"
    }
}