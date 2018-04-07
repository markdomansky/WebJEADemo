<#
.DESCRIPTION
This is the long description.  It can include <a href='www.powershell.org'>html</a> and more detailed explanation.  It will replace the synopsis if the synopsis is not supplied, otherwise the description is displayed in an expandable div.

#>
#requires -version 3

[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]

param
(

)

begin {
    
}

process {
	$VerbosePreference = 'Continue'
	
	$starttime = get-date
	write-host "Starting Jobs"
	$jobs = (1..3)|%{start-job -ArgumentList $_ -ScriptBlock {
		$sleep= get-random -max 6
		write-host "job $args - sleeping $sleep seconds"
		start-sleep -Seconds $sleep
	}} 
	write-host "Waiting for Jobs to complete."
	$jobs | Wait-Job |out-null
	write-host "Receiving jobs"
	$jobs | receive-job

	$runtime= (get-date)-$starttime
	write-host "Total runtime: $($runtime.totalseconds) seconds"
	write-host "WEBJEA: 3 jobs started."
	
}

end {
    
}
