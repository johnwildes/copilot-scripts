function Remove-GlobalAdminRole {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    $roleName = "Global Administrator"
    $role = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq $roleName}

    if ($role) {
        $user = Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'"
        
        if ($user) {
            $roleMember = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -All $true | Where-Object {$_.ObjectId -eq $user.ObjectId}
            
            if ($roleMember) {
                Remove-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RoleMemberObjectId $roleMember.ObjectId
                Write-Host "Global Administrator role removed successfully from user '$UserPrincipalName'."
            } else {
                Write-Host "User '$UserPrincipalName' is not a member of the Global Administrator role."
            }
        } else {
            Write-Host "User '$UserPrincipalName' not found."
        }
    } else {
        Write-Host "Global Administrator role not found."
    }
}