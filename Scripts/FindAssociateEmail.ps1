# This file was used to find the email addresses of the associates in the GitHub Copilot scope.
# A list of Associate IDs was provided in a CSV file. This script was used to find the email addresses of the associates.
# The script uses the Azure PowerShell module to query the Azure Active Directory for the email addresses of the associates.
# The script outputs the results to a CSV file.


# Read the input CSV file
$csvData = Import-Csv -Path "myInput.csv"

# Create an empty array to store the results
$results = @()

# Get the total number of rows in the CSV file
$totalRows = $csvData.Count

# Initialize the progress counter
$progressCounter = 0

# Open the output CSV file for writing
$outputPath = "myOutput.csv"

# Loop through each row in the CSV file
foreach ($row in $csvData) {
    # Check if the row is blank
    if ($row.AssociateUPN -ne "") {
        # Retrieve the AssociateUPN from the current row
        $associateUPN = $row.AssociateUPN

        # Find the associated user
        $associateUser = Get-AzADUser -UserPrincipalName $associateUPN

        # Retrieve the AssociateEMAIL and DisplayName from the user
        $associateEmail = $associateUser.Mail
        $associateDisplayName = $associateUser.DisplayName
        $associateOfficeLocation = $associateUser.OfficeLocation

        # Create a new object with the AssociateEMAIL and DisplayName columns
        $result = [PSCustomObject]@{
            AssociateEMAIL = $associateEmail
            DisplayName = $associateDisplayName
            OfficeLocation = $associateOfficeLocation
        }
        
        # Add the result to the array
        $results += $result
        
        # Write the result to the output file
        $result | Export-Csv -Path $outputPath -NoTypeInformation -Append
        
        # Increment the progress counter
        $progressCounter++

        # Calculate the percentage complete
        $percentComplete = ($progressCounter / $totalRows) * 100

        # Update the progress indicator
        $progressParameters = @{
            Activity = "Processing Rows"
            Status = "Percent Complete: $percentComplete%"
            PercentComplete = $percentComplete
            CurrentOperation = "Processing row $progressCounter of $totalRows"
        }
        Write-Progress @progressParameters
    }
}

# Display a message to the user
Write-Host "Processing complete. Results written to $outputPath"
