function Remove-AllResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId
    )
    
    # Connect to Azure
    Connect-AzAccount
    
    Set-AzContext -SubscriptionId $SubscriptionId

    # Get all resource groups in the subscription
    $resourceGroups = Get-AzResourceGroup
    $totalResourceGroups = $resourceGroups.Count
    $progress = 0

    Write-Host "Total resource groups found: $totalResourceGroups"

    # Delete each resource group
    foreach ($resourceGroup in $resourceGroups) {
        $progress++
        Write-Progress -Activity "Deleting resource groups" -Status "Deleting resource group: $($resourceGroup.ResourceGroupName)" -PercentComplete (($progress / $totalResourceGroups) * 100)
        Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force
    }
    
    Write-Host "All resource groups deleted."
}