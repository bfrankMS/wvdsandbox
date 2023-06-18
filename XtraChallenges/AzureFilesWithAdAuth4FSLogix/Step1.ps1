<#
    purpose: This will prepare the jump host / admin box to enable Azure files in your subscription for AD auth.
    run this on: domain member server with AD PowerShell tools installed.
    by bfrank
    reference: https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-active-directory-enable
#>


#Install Latest Nuget Package Provider
Install-PackageProvider Nuget -Force -Verbose

#Trust powershell gallery before installing
set-psrepository -Name PSGallery -installationpolicy trusted 
Install-Module -Name PowerShellGet -Force -verbose

#Unload modules to force auto reloading the new ones. 
Remove-Module PowerShellGet
Remove-Module PackageManagement

#install some required azure powershell modules before
Install-Module Az.Accounts -Force
Install-Module Az.Resources -Force
Install-Module Az.Storage -Force
Install-Module Az.Network -Force

$destinationPath = "$env:HOMEPATH\Downloads\AzFilesHybrid.zip"
$tempPath = "$env:TEMP\AzFilesHybrid"
#download module AzFilesHybrid.zip from 
# https://github.com/Azure-Samples/azure-files-samples/releases
#Invoke-WebRequest -Uri 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.2/AzFilesHybrid.zip' -OutFile $destinationPath
Invoke-WebRequest -Uri 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.7/AzFilesHybrid.zip' -OutFile $destinationPath

#unzip it
Expand-Archive $destinationPath -DestinationPath $tempPath

#Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
Set-Location $tempPath
.\CopyToPSPath.ps1 

#Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

#you need to restart the console
Read-Host 'Press any key to restart console'
exit
