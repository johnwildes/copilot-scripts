function Get-GroupMemberUPNs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    try {
        $group = Get-AzureADGroup -SearchString $GroupName
        $members = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object {$_.ObjectType -eq 'User'}
        $upns = $members | ForEach-Object {$_.UserPrincipalName}
        return $upns
    }
    catch {
        Write-Error "Failed to retrieve group members: $_"
    }
}

