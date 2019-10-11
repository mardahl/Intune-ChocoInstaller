#requires -version 5.0
<#
.SYNOPSIS
Script to install chocolatey packages via Intune Win32App
.DESCRIPTION
Combining this script with the power of Win32App deployment via Intune, you can use the official Chcolatey package repo to install applications
.REQUIREMENTS
This script must be run from the context of the SYSTEM account, unless -usermode switch is specified.', in which case it can be run as a non-admin.
Designed to be run by Intune or SCCM Agent.
.EXAMPLE
Installing greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot
    .EXAMPLE
Installing greenshot via intune Win32App in "user mode" (for apps that install into APPDATA)
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot -usermode
.EXAMPLE
Upgrading greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot -upgrade
.EXAMPLE
Uninstalling greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot -uninstall
.NOTES
The usermode switch must be used on upgrade and uninstall packages as well, if the app was originally deployed using this switch.
The switch essetially installs a seperate Chocolatey installation for each user it is deployed to, seperate of the machine wide chocolatey install.
This switch will cause up to a one minute delay in the unattended installation because of warning timeouts the chocolatey enforces on non-admins.
.COPYRIGHT
MIT License, feel free to distribute and use as you like, please leave author information.
.AUTHOR
Michael Mardahl - @michael_mardahl on twitter - BLOG: https://www.iphase.dk
Chocolatey install code inspired by https://www.petervanderwoude.nl/post/combining-the-powers-of-the-intune-management-extension-and-chocolatey/
.DISCLAIMER
This script is provided AS-IS, with no warranty - Use at own risk!
#>

PARAM(
    [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$package,
    [Parameter(Mandatory=$false)]
        [switch]$uninstall,
    [Parameter(Mandatory=$false)]
        [switch]$usermode,
    [Parameter(Mandatory=$false)]
        [switch]$upgrade
)

######
#
# CHOCOLATEY INSTALL CHECKS
#
######

# Skip download of 7z components and use Windows built-in compression
$env:chocolateyUseWindowsCompression = 'true'

if ($usermode) {

    # Trying to get around possible restrictions
    Set-ExecutionPolicy Bypass -Scope Process -Force
    # Override Chocolatey install path to enable user-mode installs (those pesky things that only install into the users APPDATA folder)
    $ChocolateyInstall = "$($env:APPDATA)\chocolatey"
    New-Item $ChocolateyInstall -Type Directory -Force
    $env:ChocolateyInstall = $ChocolateyInstall
    [Environment]::SetEnvironmentVariable("ChocolateyInstall", $ChocolateyInstall, "User")

}else{

    # Default path to Chocolatey (machine wide)
    $ChocolateyInstall = "$($env:ProgramData)\Chocolatey" #\bin\choco.exe

}

# Build path to executeable
$Choco = "$ChocolateyInstall\bin\choco.exe"

# Verify that Chocolatey is installed, otherwise try and install from the official repository.
if(!(Test-Path $Choco)) {
     try {
         Invoke-Expression ((New-Object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction stop
     }
     catch {
         Throw “Failed to install Chocolatey”
     }       
} else {
    # Try and upgrade chocolatey if it was already installed
    Write-Output "Trying to upgrade Chocolatey..."
    try {
        Invoke-Expression “cmd.exe /c $Choco upgrade chocolatey -y” -ErrorAction stop
    }
    catch {
        Write-Output “Failed to auto upgrade chocolatey”
    }
}


######
#
# PACKAGE HANDLING
#
######

# Determine if we are doing either Install or Uninstall
if($uninstall) {

    # Uninstall requested package
    try {
        Invoke-Expression “cmd.exe /c $Choco uninstall $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to uninstall $package”
    }

} elseif($upgrade) {

    # Upgrade requested package to latest approved version
    try {
        Invoke-Expression “cmd.exe /c $Choco upgrade $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to upgrade $package”
    }

} else {

    # Install requested package
    try {
        Invoke-Expression “cmd.exe /c $Choco Install $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to install $package”
    }

}