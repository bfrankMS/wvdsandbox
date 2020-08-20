<#
    purpose: This will configure FSLogix to use Azure Files.
    run this on: a session host (aka desktop)
    by bfrank
    reference: https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-active-directory-enable
#>

#downloading FSLogix.
Write-Output "downloading fslogix"
mkdir c:\temp\ -Force
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile "c:\temp\FSLogix.zip" 

Expand-Archive c:\temp\FSLogix.zip -DestinationPath c:\temp\FSLogix

#installing FSLogix
Write-Output "installing fslogix"
Start-Process -FilePath "c:\temp\FSLogix\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet" -Wait

#configuring FSLogix
Write-Output "writing fslogix keys"
Set-Location HKLM:\Software\FSLogix
New-Item HKLM:\SOFTWARE\FSLogix\Profiles
$FSLogixRegKeys = @{
    Enabled                              = 
    @{
        Type  = "DWord"
        Value = 1
    }
    VHDLocations                         = 
    @{
        Type  = "MultiString"
        Value = "\\sawvdsdboxprofiles.file.core.windows.net\wvdprofiles"
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
\\sawvdsdboxprofiles.file.core.windows.net\wvdprofiles\*\*.VHD,
\\sawvdsdboxprofiles.file.core.windows.net\wvdprofiles\*\*.VHDX
"@
foreach ($item in $excludeList) {
    Add-MpPreference -ExclusionPath $item 
}
$excludeList.Split(',')[3]
Get-MpPreference
