#get list of all locked accounts
#generate links for each of them

$users = get-aduser -ldapfilter "(anr=user999*)" | get-random -Count 4

$users | %{
    $uname=$_.samaccountname
    write-host "[[a|?cmdid=d4&username=$uname|$uname]]"
}


