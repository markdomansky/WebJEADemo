<#
.DESCRIPTION
This is the long description.  It can include <a href='www.powershell.org'>html</a> and more detailed explanation.  It will replace the synopsis if the synopsis is not supplied, otherwise the description is displayed in an expandable div.

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
#####
	#WEBJEA-DateTime
    [datetime]$BirthDate,

    [Parameter(Mandatory, HelpMessage="What service needs to be reset?")]
    [ValidateSet('Domain','ServiceA','ServiceB','ServiceC')] #any set of values you want here
    [ValidateCount(1,2)]
    [string[]]$Service,

    [Parameter(HelpMessage='Days')]
    [ValidateRange(10,90)] 
    [int16]$AccountLength = 10,

    [Parameter()]    
    [ValidateLength(10,10000)]
#####
	#WEBJEA-Multiline
    [string]$Reason,

#####
    [Parameter()]
    [boolean]$IDVerified=$true

)

begin {
    
    function New-Password() {
        return "HorseBatteryStapleCorrect!" + (get-random -max 1000)
    }

}

process {
    $VerbosePreference = 'Continue'

    
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
    Write-Host "WEBJEA:This message is logged in usage."
    #connect to HR database

    $svcs = ($service -join ', ')

    write-host "Password reset on services $svcs for $username."
    $pw = (New-Password)
    $secpw = (ConvertTo-SecureString -String $pw -AsPlainText -Force)
	set-adaccountpassword -identity $user.distinguishedname -newpassword $secpw -reset
	Set-aduser $user.distinguishedname -changepasswordatlogon $true 
		
    write-host "Password sent via text to $($user.telephonenumber)"
    #Send-MailMessage -From "webjea@domain1.local" -To "$($user.telephonenumber)@mobile.net" -Body "new password: $pw" -SmtpServer "relay.domain1.local" 

	write-verbose 'Verbose messages are displayed.'
}

end {
    
}
