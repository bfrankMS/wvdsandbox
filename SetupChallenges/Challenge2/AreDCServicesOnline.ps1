$Error.Clear()
Get-ADDomain

if ($(Get-Service ADWS).Status -ne 'Running'){
    $Error.Add("DC is not started")
}

return $Error
