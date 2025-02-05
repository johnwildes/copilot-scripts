function Update-WingetPackages {
    # Initialize counters
    $successCount = 0
    $failCount = 0

    # Get the list of upgradable packages
    $packages = Get-WingetPackage | Where-Object { $_.IsUpdateAvailable}

    # Loop through each package and attempt to upgrade
    foreach ($package in $packages) {
        try {
            # Update the package
            Update-WingetPackage $package.Id
            Write-Host "Successfully updated: $($package.Id)"
            $successCount++
        } catch {
            Write-Host "Failed to update: $($package.Id)"
            $failCount++
        }
    }

    # Report summary
    Write-Host "Summary:"
    Write-Host "Successfully updated packages: $successCount"
    Write-Host "Failed to update packages: $failCount"
}

function Get-Weather {
    param (
        [string]$apiKey
    )

    # Ask for permission to get the location
    $permission = Read-Host "Do you allow this script to access your location? (yes/no)"
    if ($permission -ne "yes") {
        Write-Host "Permission denied. Exiting..."
        return
    }

    # Get the current location
    $location = Invoke-RestMethod -Uri "http://ip-api.com/json/"
    if ($location.status -ne "success") {
        Write-Host "Failed to get location. Exiting..."
        return
    }

    $lat = $location.lat
    $lon = $location.lon

    # Get the weather information
    $weather = Invoke-RestMethod -Uri "http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric"
    if ($weather) {
        Write-Host "Current weather in $($location.city), $($location.country):"
        Write-Host "Temperature: $($weather.main.temp)°C"
        Write-Host "Weather: $($weather.weather[0].description)"
    } else {
        Write-Host "Failed to get weather information."
    }
}

# Call the function
Update-WingetPackages
