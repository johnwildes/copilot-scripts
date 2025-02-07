function Get-PowerBiAdministratorMembers {
    [CmdletBinding()]
    param()

    # Ensure the Microsoft.Graph module is available
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Error "Microsoft.Graph module is required. Run 'Install-Module Microsoft.Graph' to install it."
        return
    }

    # Connect to Microsoft Graph if not already connected
    try {
        Get-MgProfile -ErrorAction Stop | Out-Null
    }
    catch {
        Connect-MgGraph -Scopes "RoleManagement.Read.All", "User.Read.All"
    }

    # Retrieve the role definition for "PowerBi Administrator"
    try {
        $roleDefinitions = Get-MgRoleDefinition -Filter "displayName eq 'Fabric Administrator'"
    }
    catch {
        Write-Error "Failed to retrieve role definitions from Microsoft Graph."
        return
    }

    if (-not $roleDefinitions -or $roleDefinitions.Count -eq 0) {
        Write-Error "Fabric Administrator role not found."
        return
    }

    $roleDefinitionId = $roleDefinitions[0].Id

    # Get role assignments for the specified role definition
    try {
        $roleAssignments = Get-MgRoleAssignment -Filter "roleDefinitionId eq '$roleDefinitionId'"
    }
    catch {
        Write-Error "Failed to retrieve role assignments for the Fabric Administrator role."
        return
    }

    $members = @()
    foreach ($assignment in $roleAssignments) {
        try {
            # Attempt to get user details for the assignment principal.
            $user = Get-MgUser -UserId $assignment.PrincipalId -ErrorAction Stop
            $members += $user
        }
        catch {
            Write-Verbose "Skipping principal with ID $($assignment.PrincipalId) as it is not a user or cannot be retrieved."
        }
    }

    return $members
}