<#
    purpose: This will configure FSLogix to use Azure Files.
    run this on: a session host (aka desktop)
    by bfrank
    reference: https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-active-directory-enable
#>

#downloading FSLogix.
Write-Output "downloading fslogix"

$destinationPath = "$env:HOMEPATH\Downloads\FSLogix.zip"
$tempPath = "$env:TEMP\FSLogix"
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $destinationPath 

Expand-Archive $destinationPath -DestinationPath $tempPath -Force

#installing FSLogix
Write-Output "installing fslogix"
Start-Process -FilePath "$tempPath\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet" -Wait

#add administrator / domain admins to fslogix exclude local group

#configuring FSLogix
Write-Output "writing fslogix keys"
Set-Location HKLM:\Software\FSLogix
New-Item HKLM:\SOFTWARE\FSLogix\Profiles

# e.g.[Azure Portal] -> Resource Groups 'rg-wvdsdbox-basics' -> "wvdprofilesXXXX"
$storageAccountName =  Read-Host -Prompt "Please enter the name of the storage account that contains the wvdprofiles (e.g. 'wvdprofiles0815')"
$fileShareName = "wvdprofiles"

$FSLogixRegKeys = @{
    Enabled                              = 
    @{
        Type  = "DWord"
        Value = 1
    }
    VHDLocations                         = 
    @{
        Type  = "MultiString"
        Value = "\\$storageAccountName.file.core.windows.net\$fileShareName"
    }
    DeleteLocalProfileWhenVHDShouldApply =
    @{
        Type  = "DWord"
        Value = 1
    }
    VolumeType                           = 
    @{
        Type  = "String"
        Value = "VHDX"
    }
    SizeInMBs                            = 
    @{
        Type  = "DWord"
        Value = 30000
    }
    IsDynamic                            = 
    @{
        Type  = "DWord"
        Value = 1
    }
    PreventLoginWithFailure              = 
    @{
        Type  = "DWord"
        Value = 0
    }
    LockedRetryInterval                  = 
    @{
        Type  = "DWord"
        Value = 12
    }
    LockedRetryCount                     = 
    @{
        Type  = "DWord"
        Value = 12
    }
}

foreach ($item in $FSLogixRegKeys.GetEnumerator()) {
    "{0}:{1}:{2}" -f $item.Name, $item.Value.Type, $item.Value.Value
    New-ItemProperty -Type $($item.Value.Type) -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name $($item.Name) -value $($item.Value.Value)
}

<#in den session hosts - ms defender für fslogix pfade deaktivieren #>
$excludeList = @"
%ProgramFiles%\FSLogix\Apps\frxdrv.sys,
%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys,
%ProgramFiles%\FSLogix\Apps\frxccd.sys,
%TEMP%\*.VHD,
%TEMP%\*.VHDX,
%Windir%\TEMP\*.VHD,
%Windir%\TEMP\*.VHDX,
\\$storageAccountName.file.core.windows.net\$fileShareName\*\*.VHD,
\\$storageAccountName.file.core.windows.net\$fileShareName\*\*.VHDX
"@
foreach ($item in $excludeList) {
    Add-MpPreference -ExclusionPath $item 
}
$excludeList.Split(',')[3]
Get-MpPreference