<#
.DESCRIPTION
This is the long description.  It can include <a href='www.powershell.org'>html</a> and more detailed explanation.  It will replace the synopsis if the synopsis is not supplied, otherwise the description is displayed in an expandable div.

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
    [Parameter()]
    [string]$Username, 

    [Parameter()]
    [string]$WebJEAUsername,
    
    [Parameter()]
    [string]$WebJEAHostname
    
)

begin {

}

process {
    $VerbosePreference = 'Continue'

    Write-Host (Get-Date).tostring()
	Write-Host "Running as: $($env:username)"
	Write-Host "PSBoundParameters"
	$PSBoundParameters.keys | %{
		Write-Host "[[span|psbold|$_]]"
		$PSBoundParameters[$_] | write-host
		
	}

	write-verbose 'Verbose messages are displayed.'
}

end {
    
}
