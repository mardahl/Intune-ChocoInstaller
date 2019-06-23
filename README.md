# Intune-ChocoInstaller

This script was designed to make using the chocolatey package repository easy to use with Intune.
Utilizing the power of Win32app deployment.
Package this script with the Intune Content Preperation tool, and it will be the only package you will need in order to install thousands of applications!

# Useage

Once packaged as an .intunewin file
Upload to Intune, as a Win32App
Name the app according to the software you wish to install with Chocolatey- (i.e. Adobe Reader).

## Enter the following as an Installation command:
powershell -ex bypass -file ChocoInstall.ps1 -package adobereader

## Enter the following as an Uninstall command:
powershell -ex bypass -file ChocoInstall.ps1 -package adobereader -uninstall

# Credits
Peter van der Woude, for saving me time by having shared his script to check for chocolatey installation :)





