###########################################
#Pre-Demo work: Enable PSRemoting, grant access, copy files, join domain, generate certificate
############################################
#Boot DC and Web1 (snap2)
#

$cred = get-credential -UserName "domain1\administrator" -Message "Cred"

$computername = "web1.domain1.local"
get-pssession | remove-pssession
$session = New-pssession -ComputerName $computername -Credential $cred -Authentication Negotiate

remove-psdrive w -Force -ea 0
new-psdrive -name w -PSProvider filesystem -root "\\$computername\c$" -credential $cred
robocopy /mir "c:\dropbox\scripts\vb.net\webjea\release\package" "\\$computername\c$\source"
copy "C:\dropbox\scripts\PowerShell\WebJEABuild\DSC*.ps1" "\\$computername\c$\source"
copy "C:\dropbox\scripts\PowerShell\WebJEABuild\overview.ps1" "\\$computername\c$\source\startfiles"
copy "C:\dropbox\scripts\PowerShell\WebJEABuild\validate.ps1" "\\$computername\c$\source\startfiles"
copy "C:\dropbox\scripts\PowerShell\WebJEADemo\*.ps1" "\\$computername\c$\source\starterfiles"
cd C:\dropbox\scripts\powershell\WebJEADemo

############################################
#deploy
############################################
#Enter-PSSession -Session $session

invoke-command  -Session $session -scriptblock {
    cd c:\source; 
    Measure-Command {& .\dscdeploy.ps1} | fl minutes,seconds; 
    install-module WebJEAConfig -force | out-null
    cd\;
}
invoke-command -session $session -scriptblock {restart-computer}

#Minutes : 7
#Seconds : 8

#go through dscconfig
code ..\WebJEABuild\DSCConfig.inc.ps1 ..\WebJEABuild\DSCDeploy.ps1

get-pssession | remove-pssession
$session = New-pssession -ComputerName $computername -Credential $cred -Authentication negotiate 

invoke-command  -Session $session -scriptblock {
    import-module WebJEAConfig
    $configfile = "c:\scripts\config.json"
    Open-WebJEAFile -Path $configfile
    Set-WebJEAConfig -PermittedGroups @("domain1\group3") -LogParameters $true
    Get-WebJEAConfig | fl title, basepath, defaultcommandid, logparameters, permittedgroups
    Save-WebJEAFile
}

############################################
#demo1
############################################
#show basic script
code d1.ps1

invoke-command -Session $session -scriptblock {
    Open-WebJEAFile -Path $configfile
    New-WebJEACommand -CommandId 'd1' -DisplayName 'Demo1' -Script 'd1.ps1' `
        -PermittedGroups @('*')
    set-webjeaconfig -DefaultCommandId 'd1'
    Save-WebJEAFile 
}

#login to site with user1
start "https://$computername/webjea"


############################################
#add demo2
############################################
#show advanced function parsing, dates
#show script parsing, validation
code d2.ps1

invoke-command -Session $session -scriptblock {
    Open-WebJEAFile -Path $configfile
    New-WebJEACommand -CommandId 'd2' -DisplayName 'Demo2' -Script 'd2.ps1' `
        -PermittedGroups @('domain1\group3')
    Save-WebJEAFile 
}

#login to site with user1
start "https://$computername/webjea?cmdid=d2"


############################################
#add demo3
####################################d########
#shows default values
#show shows description, other validation settings 
code d3.ps1

invoke-command -Session $session -scriptblock {
    Open-WebJEAFile -Path $configfile
    New-WebJEACommand -CommandId 'd3' -DisplayName 'Demo3' -Script 'd3.ps1' `
        -PermittedGroups @('domain1\group3')
    Save-WebJEAFile 
}

#login to site with user1
start "https://$computername/webjea?cmdid=d3"


############################################
#add demo4
############################################
#show links with prefilled data
#show onload, verbose
#modifying date, string behaviors with directives
code d4o.ps1 d4.ps1

invoke-command -Session $session -scriptblock {
    Open-WebJEAFile -Path $configfile
    ##### onload, logparameters 
    New-WebJEACommand -CommandId 'd4' -DisplayName 'Demo4' -Script 'd4.ps1' `
        -OnloadScript 'd4o.ps1' -PermittedGroups @('domain1\group3') `
        -LogParameters $false
    Save-WebJEAFile 
}

#login to site with user1
start "https://$computername/webjea?cmdid=d4"

#login as user2, to show fewer scripts
& "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --incognito "https://$computername/webjea" 

############################################
#variations
############################################

invoke-command -Session $session -scriptblock {
    Open-WebJEAFile -Path $configfile
    New-WebJEACommand -CommandId 'd5' -DisplayName 'Demo5' -Script 'd5.ps1' -PermittedGroups @('domain1\group3') 
    New-WebJEACommand -CommandId 'd6' -DisplayName 'Demo6' -Script 'd6.ps1' -PermittedGroups @('domain1\group3') 
    Save-WebJEAFile 
}

#pass user/host
code d5.ps1 

start "https://$computername/webjea?cmdid=d5&username=user9999"


#no parameters
code d6.ps1

start "https://$computername/webjea?cmdid=d6"


#landing page
invoke-command -Session $session -scriptblock {
    $synopsis = @"
You can use the synopsis of the default command to present any html you want.  It does not have to have a script as part of the configuration.<br/><br/>
This can be useful as a landing page.<br/><br/>

You can use <a href="http://www.powershell.org/">Links</a> and <span class="psbold pserror">css</span>.

<a href="javascript:alert('But is that a good idea');">Even javascript</a>
"@
    Open-WebJEAFile -Path $configfile
    Set-WebJEACommand -CommandId 'overview' -synopsis $synopsis -script $null
    Set-WebJEAConfig -DefaultCommandId 'overview'
    Save-WebJEAFile 
}

start "https://$computername/webjea?cmdid=overview"

############################################
#show usage
############################################
#auditing
$usagefile = "w:\scripts\webjea-usage.log"
$usage=import-csv -Path $usagefile -Delimiter "|" `
    -Header @("dtstamp","Hostname","Username","Action","Script","RuntimeSeconds")
$usage | ft
$usage | ?{$_.action -eq "Executed"} | ft
$usage | ?{$_.action -eq "Executing"} | ft
$usage | ?{$_.action -notin @("Executed","Executing")} | ft


############################################
#show get/post
############################################
#show with passed parameters
start "https://$computername/webjea?cmdid=d4&username=user9999&employeeid=9999&birthdate=2010%2F01%2F01&Service=Domain%0D%0AServiceA&AccountLength=30&Reason=This%20is%20a%20long%20enough%20reason."

#or pass via post
code post.html

start "$pwd\post.html"

############################################
#show script template
############################################
code C:\dropbox\Scripts\PowerShell\ScriptTemplate\ScriptTemplate.ps1

