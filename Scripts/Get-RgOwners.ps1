function Get-RgOwnersList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )

    # Connect to Azure using Azure PowerShell
    Connect-AzAccount

    # Get all resource groups in the subscription
    Select-AzSubscription -SubscriptionId $SubscriptionId
    $resourceGroups = Get-AzResourceGroup

    # Iterate through each resource group
    foreach ($resourceGroup in $resourceGroups) {
        # Display progress
        Write-Progress -Activity "Checking for OWNER role assignments" -Status "Resource Group: $($resourceGroup.ResourceGroupName)"
    
        # Get role assignments for the resource group
        $roleAssignments = Get-AzRoleAssignment -ResourceGroupName $resourceGroup.ResourceGroupName
    
        # Check if there are any OWNER role assignments directly assigned and NOT inherited from management group
        $ownerRoleAssignments = $roleAssignments | Where-Object { $_.RoleDefinitionName -eq "Owner" -and $_.Scope -eq "/subscriptions/$SubscriptionId/resourceGroups/$($resourceGroup.ResourceGroupName)" }
        
        if ($ownerRoleAssignments) {
            Write-Output "Resource Group: $($resourceGroup.ResourceGroupName)"
        }
    }
}