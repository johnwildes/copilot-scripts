# Import the required Azure modules
Import-Module Az.Accounts
Import-Module Az.Resources

# Define the function to process the CSV file
function Process-UserCSV {
    param (
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory=$true)]
        [string]$CSVFileName,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId
    )
    
    # Get the storage account context
    $StorageAccountContext = Get-AzStorageAccount -Name $StorageAccountName
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccountContext.ResourceGroupName -Name $StorageAccountName).Value
    $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    
    # Download the CSV file from the storage account
    $CSVFilePath = Join-Path -Path $env:TEMP -ChildPath $CSVFileName
    Get-AzStorageBlobContent -Context $StorageContext -Container $ContainerName -Blob $CSVFileName -Destination $CSVFilePath -Force
    
    # Read the CSV file
    $Users = Import-Csv -Path $CSVFilePath
    
    # Initialize arrays to store the added and removed users
    $AddedUsers = @()
    $RemovedUsers = @()
    
    # Process each user row
    foreach ($User in $Users) {
        $UPN = $User.UPN
        $Status = $User.Status
        
        if ($Status -eq "ADD") {
            # Add role assignment as contributor to the subscription
            New-AzRoleAssignment -ObjectId $UPN -RoleDefinitionName "Contributor" -Scope "/subscriptions/$SubscriptionId"
            
            # Add the user to the added users array
            $AddedUsers += $UPN
        }
        elseif ($Status -eq "REMOVE") {
            # Remove role assignment from the subscription
            Remove-AzRoleAssignment -ObjectId $UPN -Scope "/subscriptions/$SubscriptionId"
            
            # Add the user to the removed users array
            $RemovedUsers += $UPN
        }
    }
    
    # Output the added and removed users
    Write-Output "Users Added:"
    $AddedUsers | ForEach-Object { Write-Output $_ }
    
    Write-Output "Users Removed:"
    $RemovedUsers | ForEach-Object { Write-Output $_ }
}


# Call the function with the required parameters
Process-UserCSV -StorageAccountName "<storage_account_name>" -ContainerName "<container_name>" -CSVFileName "<csv_file_name>" -SubscriptionId "<subscription_id>"