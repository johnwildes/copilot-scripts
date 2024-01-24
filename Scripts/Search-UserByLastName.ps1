# Import the required module
Import-Module AzureAD

function Search-UserByLastName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$lastName
    )

    # Get users with the last name in their UPN or DisplayName
    $users = Get-AzADUser -SearchString $lastName

    # If users are found
    if($users) {
        # Loop through each user
        foreach($user in $users) {
            # Get the user's details
            $userDetails = Get-AzADUser -ObjectId $user.Id

            # Display the user's details
            $userDetails
        }
    } else {
        Write-Host "No users found with the last name $lastName"
    }
}

