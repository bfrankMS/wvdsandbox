# Challenge 0: Setup Basics i.e. Network, AD, FS and do an AAD Sync using AD Connect

[back](../README.md)

In this challenge we will setup the basics requied for the WVD Sandbox. In order to save time we will use the Azure Cloud Shell to run some PowerShell code.  
> **Note**: With the use of Azure Cloud Shell we don't need to install something on your local box. No version conflics. And you are already authenticated at Azure ;-)

## 0. Create an Azure Cloud Shell - if you don't have one. :-)
```
[Azure Portal] -> Click the 'Cloud Shell' symbol close to your login details on the right upper corner.
```  
![Cloud Shell](CloudShell.png))  
The **'Cloud Shell' is an in-browser-accessible shell for managing Azure resources**. It already has the required SDKs and tools installed to interact with Azure. You can use either Bash or PowerShell.  
When being asked **choose PowerShell this time**.  
**The first time you use the 'Cloud Shell' you will be asked to setup a storage account** e.g. to store files you have uploaded persistently. [See](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage)  

```
[Azure Portal] -> Click 'Show advanced settings'
```  
![Cloud Shell Storage Account Setup](CloudShell1.png)  

| Name | Value |
|---|---|
| Subscription  |  _your subscription_ |
| Cloud Shell Region  |  e.g. **West Europe** |   
| Resource Group  |  e.g. **rg-cloudshell** |   
| Storage Account  |  **_some unique value_** |   
| File Share  |  **cloudshell**|   

```
[Azure Portal] -> Create storage
```  
Once successful your shell should appear at the bottom of the page:  
![Cloud Shell in the Azure portal](CloudShell2.png)

## 1. Let's create some Resource Groups
Make sure you are using the right subscription, e.g. 
```PowerShell
Get-AzContext  
```  
Should give clarity. 
> To use a different subscription to deploy to you might try:  
>```PowerShell
>Get-AzSubscription 
>
>Set-AzContext -Subscription '%SubscriptionName%' 
>```  

Now let's **create some Resource Groups copy & paste the following code into the Cloud Shell**:  
```PowerShell
$RGPrefix = "rg-wvdsdbox-"
$RGSuffixes = @("basics","hostpool-1","hostpool-2","hostpool-3")
$RGLocation = 'westeurope'   # for alternatives try: 'Get-AzLocation | ft Location'

foreach ($RGSuffix in $RGSuffixes)
{
   New-AzResourceGroup -Name "$($RGPrefix)$($RGSuffix)" -Location $RGLocation
}
```  
As result you should get something like:  
![Some Resource Groups](SomeRGs.PNG)

## 2. Create the Network and Servers.
```PowerShell


```