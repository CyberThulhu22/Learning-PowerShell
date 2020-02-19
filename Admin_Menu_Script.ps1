do{
function Pause{Read-Host 'Press Enter to continue...' | Out-Null
}do{
$hostcomputername = hostname
$userloggedin = $env:USERNAME
$RootDSE = "LDAP://RootDSE"
$DNSDomain = Get-ADRootDSE | Select defaultNamingContext
$de = "LDAP://$DNSDomain"
clear
write-host "====="
write-host "Currently on computer:"$hostcomputername
write-host "Current user:"$userloggedin
write-host "====="
write-host "1. IPConfig Menu"
write-host "2. "
write-host "3. Force Reboot Computer"
Write-host "Exit. "
write-host "====="
write-host -nonewline "Type your choice and press Enter:"
$choice = read-host
write-host ""
$ok = @() -contains $choice
if(-not $ok){write-host "Invalid selection"
}
}until($ok)
switch($choice){
"1"{
do{
Write-Host "====================="
Write-Host "    IPConfig Menu    "
Write-Host "====================="
Write-Host "1. IPConfig          "
Write-Host "2. IPConfig /All     "
Write-Host "3. IPConfig /Release "
Write-Host "4. IPConfig /Renew   "
Write-Host "5. IPConfig /FlushDNS"
Write-Host "====================="
Write-Host -nonewline "Please make a selection and press Enter:"
Write-Host ""
$choice1 = read-host
Write-Host ""
$ok1 = @("1","2","3","4","5") -contains $choice1
if(-not $ok1){Write-Host "Invalid Selection"}
}
until($ok1)
switch($choice1){
"1"{IPConfig}
"2"{IPConfig /all}
"3"{IPConfig /release}
"4"{IPConfig /renew}
"5"{IPConfig /flushdns}
}
pause
break
}

"2"{
pause
break
}

"3"{
pause
break
}
}
clear
}
until($choice -eq "Exit"
)