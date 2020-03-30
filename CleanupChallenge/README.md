# For Cleanup You Need To...

[back](../README.md)  

1. Remove WVD Artefacts (Application Groups, Host Pools, WVD Tenant)
2. Break AAD Sync. Cleanup Users. Delete WVD Apps.
3. Delete Azure Artefacts (e.g. VMs., Network,...)



## 1. Remove WVD Artefacts (Application Groups, Host Pools, WVD Tenant)
**RDP into your jumpserver**:  
```
Internet ---RDP---> wvdsdbox-FS-VM1 (Public IP)
```  
> **Important**: You **cannot use the azure cloud shell** for this code (_is running PScore >= 7.0_). It **must be PowerShell version 5.1|5.0.** 
```PowerShell
Import-Module -Name Microsoft.RDInfra.RDPowerShell 

#Sign in to Windows Virtual Desktop
$azureCredential = Get-Credential -Message "Please Enter Your AAD Tenant Creator Credentials"   #in my case admin@contoso4711.nmicrosoft.com
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $azureCredential   

#Make Some Selections
$tenantName = (Get-RdsTenant | Out-GridView -Title 'Select Your WVD Tenant' -OutputMode Single).TenantName
$hostPoolName = (Get-RdsHostPool -TenantName $tenantName | Out-GridView -Title "Select Your Host Pool" -OutputMode Single).ostPoolName

#remove all users on all app groups
$AppGroupNames = @()
$AppGroupNames = Get-RdsAppGroup -TenantName $tenantName -HostPoolName $hostPoolName | %{$AppGroupNames += $_.AppGroupName} 
foreach ($AppGroupName in $AppGroupNames)
{
    #Remove App Group Users
    $appGroupUsers = @()
    Get-RdsAppGroupUser -TenantName $tenantName -HostPoolName $hostPoolName -AppGroupName $AppGroupName | %{$appGroupUsers += $_.UserPrincipalName}
    $appGroupUsers | %{  Remove-RdsAppGroupUser -TenantName $tenantName -HostPoolName $hostPoolName -AppGroupName $AppGroupName -UserPrincipalName $_}  
}

Get-RdsSessionHost -TenantName $tenantName -HostPoolName $hostPoolName | % {Remove-RdsSessionHost -TenantName $_.TenantName HostPoolName $_.HostPoolName -Name $_.SessionHostName -Verbose -Force}
Get-RdsAppGroup  -TenantName $tenantName -HostPoolName $hostPoolName | % {Remove-RdsAppGroup -TenantName $_.TenantName HostPoolName $_.HostPoolName -Name $_.AppGroupName -Verbose}

#if you have apps in you app group
#$appGroupsToRemove = @()
#Get-RdsAppGroup -TenantName $tenantName -HostPoolName $hostPoolName <#-Name $newAppGroupName#> | Out-GridView -Title "Select pp groups to delete" -OutputMode Multiple | % { $appGroupsToRemove += $_.AppGroupName}
#$appGroupsToRemove | % {Get-RdsRemoteApp -TenantName $tenantName -HostPoolName $hostPoolName -AppGroupName $_ | emove-RdsRemoteApp ; Remove-RdsAppGroup -TenantName $tenantName -HostPoolName $hostPoolName -Name $_}

#remove the hostpool
Remove-RdsHostPool -TenantName $tenantName -Name $hostPoolName -Verbose

#Remove RDS Tenant
Remove-RdsTenant -TenantName $tenantName  

```

## 2. Break AAD Sync. Cleanup Users. Delete WVD Apps.
**RDP into your jumpserver**:  
```
Internet ---RDP---> wvdsdbox-FS-VM1 (Public IP)
```  
and open PowerShell ISE as Administrator and run the code below:   
```PowerShell
Install-Module -Name MSonline

#specify credentials for azure ad connect
$Msolcred = Get-credential
#connect to azure ad
Connect-MsolService -Credential $MsolCred
 
#disable AD Connect / Dir Sync
Set-MsolDirSyncEnabled –EnableDirSync $false
 
#confirm AD Connect / Dir Sync disabled
(Get-MSOLCompanyInformation).DirectorySynchronizationEnabled

#remove Synced Accounts from your AAD
Get-MsolUser | Where-Object DisplayName -Like "WVDUser*" | Remove-MsolUser -Force
Get-MsolUser | Where-Object DisplayName -Like "On-Premises Directory Synchronization Service Account
Sync*" | Remove-MsolUser -Force

#Remove the service principals for the WVD Enterprise Applications in your AAD
Get-MsolServicePrincipal | Where-Object DisplayName -Like "Windows Virtual Desktop*" | %{Remove-MsolServicePrincipal ObjectId $_.ObjectId }  

```
  
## 3. Delete Azure Artefacts (e.g. VMs., Network,...)
**Copy & Paste this code into your Cloud Shell**. It will destroy the WVD sandbox RGs containing the all azure artefacts.  
Saved all your work? Think again. Following code makes no backup ;-)

```PowerShell
$RGPrefix = "rg-wvdsdbox-"
$RGSuffixes = @("basics","hostpool-1","hostpool-2","hostpool-3")
$RGLocation = 'westeurope'   # for alternatives try: 'Get-AzLocation | ft Location'
foreach ($RGSuffix in $RGSuffixes)
{
    Remove-AzResourceGroup -Name "$($RGPrefix)$($RGSuffix)" -Force -AsJob
}
while (get-job -State Running)
{
    get-job
    "- - - - -"
    sleep 10
}  

```

[back](../README.md)  