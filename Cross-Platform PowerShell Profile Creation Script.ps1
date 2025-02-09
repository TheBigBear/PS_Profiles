# Cross-Platform PowerShell Profile Creation Script

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

# Detect the operating system
$osType = if ($IsWindows) {
    "Windows"
} elseif ($IsMacOS) {
    "macOS"
} elseif ($IsLinux) {
    "Linux"
} else {
    throw "Unsupported operating system."
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
    Create-Profile -profilePath $currentProfiles[$profileType] -profileType $profileType -osType $osType
}

# On Windows, handle both Windows PowerShell 5.x and PowerShell Core 7.x
if ($osType -eq "Windows") {
    if ($psVersion -eq 5) {
        # If running in Windows PowerShell 5.x, call PowerShell Core 7.x
        $otherPsPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if ($otherPsPath) {
            Write-Host "Detected Windows PowerShell 5.x. Calling PowerShell Core 7.x to create its profiles..."
            & $otherPsPath -Command {
                $otherProfiles = @{
                    AllUsersAllHosts = $PROFILE.AllUsersAllHosts
                    AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
                    CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
                    CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
                }
                foreach ($profileType in $otherProfiles.Keys) {
                    Create-Profile -profilePath $otherProfiles[$profileType] -profileType $profileType -osType "Windows"
                }
            }
        } else {
            Write-Host "PowerShell Core 7.x is not installed. Skipping profile creation for PowerShell Core."
        }
    } elseif ($psVersion -eq 7) {
        # If running in PowerShell Core 7.x, call Windows PowerShell 5.x
        $otherPsPath = (Get-Command powershell -ErrorAction SilentlyContinue).Source
        if ($otherPsPath) {
            Write-Host "Detected PowerShell Core 7.x. Calling Windows PowerShell 5.x to create its profiles..."
            & $otherPsPath -Command {
                $otherProfiles = @{
                    AllUsersAllHosts = $PROFILE.AllUsersAllHosts
                    AllUsersCurrentHost = $PROFILE.AllUsersCurrentHost
                    CurrentUserAllHosts = $PROFILE.CurrentUserAllHosts
                    CurrentUserCurrentHost = $PROFILE.CurrentUserCurrentHost
                }
                foreach ($profileType in $otherProfiles.Keys) {
                    Create-Profile -profilePath $otherProfiles[$profileType] -profileType $profileType -osType "Windows"
                }
            }
        } else {
            Write-Host "Windows PowerShell 5.x is not installed. Skipping profile creation for Windows PowerShell."
        }
    }
}

Write-Host "Profile creation process completed."