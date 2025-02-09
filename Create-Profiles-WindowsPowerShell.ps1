# Script for Windows PowerShell 5.x

# Check if running in Windows PowerShell 5.x
if ($PSVersionTable.PSVersion.Major -ne 5 -or $PSVersionTable.PSEdition -ne "Desktop") {
    Write-Host "This script is designed to run in Windows PowerShell 5.x. Exiting."
    exit
}

# Define the Create-Profile function
function Create-Profile {
    param (
        [string]$profilePath,
        [string]$profileType,
        [string]$osType
    )

    # Check if the profile file exists
    if (-not (Test-Path $profilePath)) {
        # Create the profile file
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Host "Created profile: $profilePath"
    } else {
        # Backup the existing profile file
        $backupPath = "$profilePath.bak"
        $backupIndex = 1
        while (Test-Path $backupPath) {
            $backupPath = "$profilePath.bak.$backupIndex"
            $backupIndex++
        }
        Copy-Item -Path $profilePath -Destination $backupPath -Force
        Write-Host "Backed up existing profile to: $backupPath"
    }

    # Define OS-specific comments
    $osComment = switch ($osType) {
        "Windows" { "# OS: Windows" }
        "macOS"   { "# OS: macOS" }
        "Linux"   { "# OS: Linux" }
    }

    # Define the comments for the profile file
    $comments = @"
# Type: $profileType
# Path: $profilePath
$osComment
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

    # Check if the comments already exist in the profile file
    $existingContent = Get-Content -Path $profilePath -Raw
    if (-not ($existingContent -like "*$comments*")) {
        # Add comments to the profile file
        $comments | Set-Content -Path $profilePath
        Write-Host "Added comments to profile: $profilePath"
    } else {
        Write-Host "Comments already exist in profile: $profilePath"
    }
}

# Define the profile paths for Windows PowerShell 5.x
$currentProfiles = @{
    AllUsersAllHosts = $PROFILE.AllUsersAllHosts
    AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
    CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
    CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
}

# Create profiles for Windows PowerShell 5.x
foreach ($profileType in $currentProfiles.Keys) {
    $profilePath = $currentProfiles[$profileType]
    if ($profilePath) {
        Create-Profile -profilePath $profilePath -profileType $profileType -osType "Windows"
    } else {
        Write-Host "Profile path for $profileType is empty. Skipping."
    }
}

Write-Host "Profile creation process completed for Windows PowerShell 5.x."