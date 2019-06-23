#requires -runasadministrator
#requires -version 5.0
<#
.SYNOPSIS
Script to install chocolatey packages via Intune Win32App
.DESCRIPTION
Combining this script with the power of Win32App deployment via Intune, you can use the official Chcolatey package repo to install applications
.REQUIREMENTS
This script must be run from the context of the SYSTEM account.
Designed to be run by Intune or SCCM Agent.
.EXAMPLE
Installing greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot
.EXAMPLE
Upgrading greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot -upgrade
.EXAMPLE
Uninstalling greenshot via intune Win32App
    Install command: powershell -ex bypass -file ChocoInstall.ps1 -package greenshot -uninstall
.COPYRIGHT
MIT License, feel free to distribute and use as you like, please leave author information.
.AUTHOR
Michael Mardahl - @michael_mardahl on twitter - BLOG: https://www.iphase.dk
Greenshot install code borrowed from https://www.petervanderwoude.nl/post/combining-the-powers-of-the-intune-management-extension-and-chocolatey/
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
        [switch]$upgrade
)

#Path to Chocolatey
$ChocoInstall = Join-Path ([System.Environment]::GetFolderPath("CommonApplicationData")) "Chocolatey\bin\choco.exe"

#Verify Chcolatey is installed, otherwise try and install from official repository.
if(!(Test-Path $ChocoInstall)) {
     try {
         Invoke-Expression ((New-Object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
     }
     catch {
         Throw “Failed to install Chocolatey”
     }       
}

#Determine if we are doing either Install or Uninstall
if($uninstall) {

    #Uninstall requested package
    try {
        Invoke-Expression “cmd.exe /c $ChocoInstall uninstall $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to uninstall $package”
    }

} elseif($upgrade) {

    #Upgrade requested package to latest approved version
    try {
        Invoke-Expression “cmd.exe /c $ChocoInstall upgrade $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to upgrade $package”
    }

} else {

    #Install requested package
    try {
        Invoke-Expression “cmd.exe /c $ChocoInstall Install $package -y” -ErrorAction Stop
    }
    catch {
        Throw “Failed to install $package”
    }

}