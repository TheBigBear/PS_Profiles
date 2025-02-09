# Auto-Detect PowerShell Version and Create Profiles for Both 5.x and 7.x

function Create-Profile {
    param (
        [string]$profilePath,
        [string]$profileType
    )

    # Check if the profile file exists
    if (-not (Test-Path $profilePath)) {
        # Create the profile file
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Host "Created profile: $profilePath"
    }

    # Check if the comments already exist in the profile file
    $comments = @"
# Type: $profileType
# Path: $profilePath
# Usage: This profile is loaded for $(
    if ($profileType -eq "AllUsersAllHosts") {
        "all users and all hosts."
    } elseif ($profileType -eq "AllUsersCurrentHost") {
        "all users and the current host."
    } elseif ($profileType -eq "CurrentUserAllHosts") {
        "the current user and all hosts."
    } elseif ($profileType -eq "CurrentUserCurrentHost") {
        "the current user and the current host."
    }
)
"@

    $existingContent = Get-Content -Path $profilePath -Raw
    if (-not ($existingContent -like "*$comments*")) {
        # Add comments to the profile file
        $comments | Set-Content -Path $profilePath
        Write-Host "Added comments to profile: $profilePath"
    } else {
        Write-Host "Comments already exist in profile: $profilePath"
    }
}

# Get the current PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major

# Define the profile paths for the current PowerShell version
$currentProfiles = @{
    AllUsersAllHosts = $PROFILE.AllUsersAllHosts
    AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
    CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
    CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
}

# Create profiles for the current PowerShell version
foreach ($profileType in $currentProfiles.Keys) {
    Create-Profile -profilePath $currentProfiles[$profileType] -profileType $profileType
}

# Determine the other PowerShell version and create its profiles
if ($psVersion -eq 5) {
    # If running in Windows PowerShell 5.x, call PowerShell Core 7.x
    $otherPsPath = (Get-Command pwsh).Source
    Write-Host "Detected Windows PowerShell 5.x. Calling PowerShell Core 7.x to create its profiles..."
    & $otherPsPath -Command {
        $otherProfiles = @{
            AllUsersAllHosts = $PROFILE.AllUsersAllHosts
            AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
            CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
            CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
        }
        foreach ($profileType in $otherProfiles.Keys) {
            Create-Profile -profilePath $otherProfiles[$profileType] -profileType $profileType
        }
    }
} elseif ($psVersion -eq 7) {
    # If running in PowerShell Core 7.x, call Windows PowerShell 5.x
    $otherPsPath = (Get-Command powershell).Source
    Write-Host "Detected PowerShell Core 7.x. Calling Windows PowerShell 5.x to create its profiles..."
    & $otherPsPath -Command {
        $otherProfiles = @{
            AllUsersAllHosts = $PROFILE.AllUsersAllHosts
            AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
            CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
            CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
        }
        foreach ($profileType in $otherProfiles.Keys) {
            Create-Profile -profilePath $otherProfiles[$profileType] -profileType $profileType
        }
    }
} else {
    Write-Host "Unsupported PowerShell version detected: $psVersion"
    exit 1
}

Write-Host "Profile creation process completed."