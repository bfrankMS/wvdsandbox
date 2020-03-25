#this will be our temp folder - need it for download / logging
$tmpDir = "c:\temp\" 

#create folder if it doesn't exist
if (!(Test-Path $tmpDir)) { mkdir $tmpDir -force }

#write a log file with the same name of the script
Start-Transcript "$tmpDir\$($SCRIPT:MyInvocation.MyCommand).log"

#To install AD we need PS support for AD first
$features = @("FileAndStorage-Services", "File-Services", "FS-FileServer", "FS-Data-Deduplication", "Storage-Services", "RSAT-AD-Tools", "RSAT-AD-AdminCenter", "RSAT-ADDS-Tools", "RSAT-AD-PowerShell", "RSAT-ADDS", "RSAT-ADLDS", "RSAT-AD-Tools"    )
Install-WindowsFeature -Name $features -Verbose 

#Download some tools. e.g. for benchmarking storage IO
$Downloads = @( "https://vorboss.dl.sourceforge.net/project/iometer/iometer-stable/1.1.0/iometer-1.1.0-win64.x86_64-bin.zip")

foreach ($download in $Downloads) {
    $downloadPath = $tmpDir + "\$(Split-Path $download -Leaf)"
    if (!(Test-Path $downloadPath )) { #download if not there
        $bitsJob = start-bitstransfer "$download" "$downloadPath" -Priority High -RetryInterval 60 -Verbose -TransferType Download #wait until downloaded.
        Get-BitsTransfer -Verbose -AllUsers
    }
}

#Do we find Data disks (raw by default) in this VM? 
$RawDisks = Get-Disk | where PartitionStyle -eq "RAW"

$driveLetters = ("f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")

$i = 0
foreach ($RawDisk in $RawDisks) {
    $currentDriveLetter = $driveLetters[$i]

    New-Volume -DiskNumber $RawDisk.Number -FriendlyName "Data$i" -FileSystem NTFS -DriveLetter $currentDriveLetter
    $myDir = "$($currentDriveLetter):\Profiles"
    mkdir $myDir
    # Create folder MD X:\VMS # Create file share 
    New-SmbShare -Name "Profiles$i" -Path "$myDir" -FullAccess "Everyone"
    # Set NTFS permissions from the file share permissions 
    #(Get-SmbShare "Profiles0").PresetPathAcl | Set-Acl 

    $userDomain = (Get-Item Env:\USERDOMAIN).value

    $users = @("$userDomain\Domain Admins", "$userDomain\WVD Users")
    foreach ($user in $users) {
        $acl = get-acl -path $myDir
        $new = $user, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
        $accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $new
        $acl.AddAccessRule($accessRule)
        $acl | Set-Acl $myDir
    }

    for ($i = 1; $i -le 15; $i++) { 
        $aduser = Get-ADUser -Filter "Name -like ""WVDUser$i"""
        $userProfilePath = "$myDir\$($aduser.SID)WVDUser$i"
        mkdir $userProfilePath
        $users = @("$userDomain\Domain Admins", "$userDomain\$($aduser.Name)")
        $acl = get-acl -path $userProfilePath
        $acl.SetAccessRuleProtection($true, $false)
        $acl | Set-Acl
        foreach ($user in $users) {
            $new = $user, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
            $accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $new
            $acl.AddAccessRule($accessRule)
            $acl | Set-Acl $userProfilePath
        }
    }

    $i++
}

stop-transcript
