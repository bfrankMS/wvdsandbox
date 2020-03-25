param(
    [Parameter(Mandatory=$True,Position=1)]
    [string] $OUName,

    [Parameter(Mandatory=$True,Position=2)]
    [string] $WVDUsersPassword
)

#this will be our temp folder - need it for download / logging
$tmpDir = "c:\temp\" 

#create folder if it doesn't exist
if (!(Test-Path $tmpDir)) { mkdir $tmpDir -force}

#write a log file with the same name of the script
Start-Transcript "$tmpDir\$($SCRIPT:MyInvocation.MyCommand).log"

Import-Module ActiveDirectory
$DomainPath = $((Get-ADDomain).DistinguishedName) # e.g."DC=contoso,DC=azure"

#region add OU for 'WVDUsers'
    "Creating OU:{0} in Domain:{1} on Server:{2}" -f $OUName,$DomainPath,$hostname
    New-ADOrganizationalUnit -Name:$OUName -Path:$DomainPath -ProtectedFromAccidentalDeletion:$true 
    Set-ADObject -Identity:"OU=$OUName,$DomainPath" -ProtectedFromAccidentalDeletion:$true 
    
    for ($i = 1; $i -le 10; $i++)
    { 
        New-ADOrganizationalUnit -Name:"HostPool$i" -Path:"OU=$OUName,$DomainPath" -ProtectedFromAccidentalDeletion:$true 
    }
#endregion 

#region add Sec Group "WVD Users"
    New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"WVD Users" -Path:"OU=$OUName,$DomainPath" -SamAccountName:"WVD Users" 
#endregion

#region create some WVD test users
    $ADPath = "OU=$OUName,$DomainPath"

    for ($i = 1; $i -le 15; $i++)
    { 
        $userName = "WVDUser$i"
        $Identity = "CN=$userName" +"," +$ADPath
        if ((Get-ADUser -Identity $Identity) -ne $null)  {Write-Output "$Identity already exists"; continue}
        $user = New-ADUser -Path:$ADPath `
        -Name $userName `
        -DisplayName $userName `
        -Enabled $false `
        -PassThru -UserPrincipalName $("$userName@"+$((Get-ADDomain).Forest))
        
        #Add-ADPrincipalGroupMembership -Identity:$user.DistinguishedName -MemberOf:"CN=Remote Desktop Users,CN=Builtin,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
        Set-ADGroup -Add:@{'Member'="CN=$userName,$ADPath"} -Identity:"CN=WVD Users,$ADPath" 

        $UserPassword = ConvertTo-SecureString $WVDUsersPassword -AsPlainText -Force 
        Set-ADAccountPassword -Identity:$user.DistinguishedName -NewPassword:$UserPassword -Reset:$true 
        Set-ADObject -Identity:$user.DistinguishedName -Replace:@{"userAccountControl"="512"}   #enable account
        Set-ADUser -ChangePasswordAtLogon:$false -Identity:$user.DistinguishedName
    }


#endregion
stop-transcript
