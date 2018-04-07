<#
.SYNOPSIS
Select the services you want to reset and enter the user account to reset.  Then supply validation information.

.PARAMETER Username
The username of the employee to reset the password for.

.PARAMETER EmployeeID
Employee ID of user.

.PARAMETER BirthDate
Birthdate as stored in HR database.

.PARAMETER Service
Which service(s) to reset the password for.

#>
#requires -version 3

[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]

param
(
    [Parameter(Mandatory, HelpMessage="What user's password needs to be reset?")]
    #[ValidateLength(3,30)]
    [ValidatePattern("user\d{4}")]
    [string]$Username, 
		
    [Parameter(Mandatory=$true, HelpMessage = "What is the user's employee id?")]
    #[ValidateLength(4,4)]
    [ValidatePattern("\d{4}")]
    [int16]$EmployeeID,

    [Parameter(Mandatory=$true, HelpMessage = "What is the user's Birthdate?")]
    [datetime]$BirthDate,

    [Parameter(Mandatory, HelpMessage="What service needs to be reset?")]
    [ValidateSet('Domain','ServiceA','ServiceB','ServiceC')]
    [string[]]$Service

)

begin {
    
    function New-Password() {
        return "HorseBatteryStapleCorrect!" + (get-random -max 1000)
    }

}

process {

    
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
    
    write-host "Validating Birthdate"
    #connect to HR database

    $svcs = ($service -join ', ')

    write-host "Password reset on services $svcs for $username."
    $pw = (New-Password)
    $secpw = (ConvertTo-SecureString -String $pw -AsPlainText -Force)
    set-adaccountpassword -identity $user.distinguishedname -newpassword $secpw -reset
    Set-aduser $user.distinguishedname -changepasswordatlogon $true 
        
    write-host "Password sent via text to $($user.telephonenumber)"
    #Send-MailMessage -From "webjea@domain1.local" -To "$($user.telephonenumber)@mobile.net" -Body "new password: $pw" -SmtpServer "relay.domain1.local" 

}

end {
    
}
