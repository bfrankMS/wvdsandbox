<#
    purpose: This will prepare the jump host / admin box to enable Azure files in your subscription for AD auth.
    run this on: domain member server with AD PowerShell tools installed.
    by bfrank
    reference: https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-active-directory-enable
#>

#trust powershell gallery before installing
set-psrepository -Name PSGallery -installationpolicy trusted 

#install some required azure powershell modules before
Install-Module Az.Accounts -Force
Install-Module Az.Resources -Force
Install-Module Az.Storage -Force
Install-Module Az.Network -Force

#download module AzFilesHybrid.zip from 
# https://github.com/Azure-Samples/azure-files-samples/releases
Invoke-WebRequest -Uri 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.0/AzFilesHybrid.zip' -OutFile c:\temp\AzFilesHybrid.zip

#unzip it
Expand-Archive c:\temp\AzFilesHybrid.zip -DestinationPath C:\temp\AzFilesHybrid

#Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
cd c:\temp\AzFilesHybrid
.\CopyToPSPath.ps1 

#Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

#you need to restart the console