# Get all subscriptions
$subscriptions = Get-AzSubscription -TenantId de08c407-19b9-427d-9fe8-edf254300ca7

# Initialize an array to hold the results
$results = @()

foreach ($subscription in $subscriptions) {
    # Skip subscriptions that are in the "Disabled" state
    if ($subscription.State -eq 'Disabled') {
        continue
    }

    # Set the context to the current subscription
    Set-AzContext -SubscriptionId $subscription.Id

    # Get the role assignments for the current subscription
    $roleAssignments = Get-AzRoleAssignment

    # Filter the role assignments to get only Owners and Contributors
    $ownersAndContributors = $roleAssignments | Where-Object { $_.RoleDefinitionName -eq 'Owner' -or $_.RoleDefinitionName -eq 'Contributor' }

    # Get the UPNs of the owners and contributors
    $upns = $ownersAndContributors | ForEach-Object { $_.SignInName } | Sort-Object | Get-Unique -AsString

    # Join the UPNs with a semicolon
    $upnsString = $upns -join ';'

    # Create a custom object for the current subscription
    $result = [PSCustomObject]@{
        SubscriptionName = $subscription.Name
        SubscriptionId   = $subscription.Id
        OwnersAndContributors = $upnsString
    }

    # Add the custom object to the results array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path "SubscriptionsOwnersAndContributors.csv" -NoTypeInformation

Write-Output "CSV file has been created successfully."