param ($username, $employeeid)
function New-Password() {
    return "HorseBatteryStapleCorrect!" + (get-random -max 1000)
}

Write-Host "Validating username"
$user = $null
try {
    $user = get-aduser $username -properties *
} catch {
    write-host "User not found"
    return
}

write-host "Validating employeeid"
if ($user.employeeid -ne $employeeid) {
    write-host "Employee id validation failed."
    return
}

write-host "Password reset for $username."
$pw = (New-Password)
$secpw = (ConvertTo-SecureString -String $pw -AsPlainText -Force)
set-adaccountpassword -identity $user.distinguishedname -newpassword $secpw -reset
Set-aduser $user.distinguishedname -changepasswordatlogon $true 

write-host "Password reset to '$pw'."