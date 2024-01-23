# This function is used to calculate the space-time of an object.
# The space-time is the distance traveled by an object in a given time.
# The function takes the following parameters:
# - The distance traveled by the object
# - The velocity of the object
# The function returns the space-time of the object.
# Generated by GitHub Copilot
# Edited by: John Wildes
# Date: 23JAN2024
# Version: 1.0.0



function Get-SpaceTime {
    param (
        [double]$distance,
        [double]$velocity
    )

    $time = $distance / $velocity
    $spaceTime = $distance * $time

    return $spaceTime
}
