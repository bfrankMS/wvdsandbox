# For Cleanup You Need To...

[back](../README.md)  

1. Break AAD Sync. Cleanup Users.
2. Remove WVD Artefacts (Application Groups, Host Pools)
3. Delete other Azure Artefacts (e.g. VMs., Network,...)


## 1. Break AAD Sync. Cleanup Users. Delete WVD Apps.
**RDP into your jumpserver**:  
```
Internet ---RDP---> wvdsdbox-FS-VM1 (Public IP)
```  
and open PowerShell ISE as Administrator and run the code below:   
```PowerShell
Install-Module -Name MSonline -Force

#specify credentials for azure ad connect
$Msolcred = Get-credential -Message "Please Enter Your AAD Tenant Creator Credentials"
#connect to azure ad
Connect-MsolService -Credential $MsolCred
 
#disable AD Connect / Dir Sync
Set-MsolDirSyncEnabled –EnableDirSync $false -Force
 
#confirm AD Connect / Dir Sync disabled
(Get-MSOLCompanyInformation).DirectorySynchronizationEnabled

#remove Synced Accounts from your AAD
Get-MsolUser | Where-Object DisplayName -Like "WVDUser*" | Remove-MsolUser -Force 
Get-MsolUser | Where-Object DisplayName -Like "On-Premises Directory Synchronization Service Account*" | Remove-MsolUser -Force  
Get-MsolUser -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force

#Remove the service principals for the WVD Enterprise Applications in your AAD
Get-MsolServicePrincipal | Where-Object DisplayName -Like "Windows Virtual Desktop*" | %{Remove-MsolServicePrincipal -ObjectId $_.ObjectId }

#Remove the app registration for the  Windows Virtual Desktop Svc Principal 
if (!(get-module azuread -ListAvailable)) {Install-Module AzureAD -Force}
Connect-AzureAD -Credential $MsolCred
Get-AzureADApplication | Where-Object DisplayName -Like "Windows Virtual Desktop*" | %{Remove-AzureADApplication -ObjectId $_.ObjectId}

#Clear the AAD recycle bin for apps  
Get-AzureADDeletedApplication -all 1 | ForEach-Object { Remove-AzureADdeletedApplication -ObjectId $_.ObjectId  } 


```

## 2. Remove WVD Artefacts (Application Groups, Host Pools)
```PowerShell
Install-Module -Name Az.DesktopVirtualization -Force

$hostPools = Get-AzWvdHostPool

foreach ($hostPool in $hostPools)
{
	$hostPool.Name
	$RG = $(Get-AzResource -ResourceType 'Microsoft.DesktopVirtualization/hostpools' -ResourceName $($hostPool.Name)).ResourceGroupName
	$sessionHosts = Get-AzWvdSessionHost -HostPoolName $hostPool.Name -ResourceGroupName $RG 
	foreach ($sessionHost in $sessionHosts)
	{	"removing session host: $(split-path $($sessionHost.Name) -leaf) "
		Remove-AzWvdSessionHost -ResourceGroupName $RG -HostPoolName $($hostPool.Name) -Name $(split-path $($sessionHost.Name) -leaf) 
	}
}

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

# Report that you have cleaned up - this code will only trigger a website to raise a counter++ - i.e. no private data (e.g. ipaddresses will be transmitted)
$apiURL = "https://bfrankpageviewcounter.azurewebsites.net/api/GetPageViewCount"
$body = @{URL='wvdsdbox-cleanup'} | ConvertTo-Json
$webrequest = Invoke-WebRequest -Method Post -Uri $apiURL -Body $body -ContentType 'application/json'
Write-Output $("URL: '{0}' has been counted: '{1}' times" -f $(($body | ConvertFrom-Json).URL), $webrequest.Content)
  


```

[back](../README.md)  