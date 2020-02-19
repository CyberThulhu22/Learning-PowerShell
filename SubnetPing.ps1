function Report_File{

    $MainReportFilePath = "$env:USERPROFILE\Desktop\ADMIN_REPORTS\"
    $ReportFileName = Get-Date -Format "'Reports'(dd-MMM-yyyy)"
    $ReportFilePath = "$env:USERPROFILE\Desktop\ADMIN_REPORTS\$ReportFileName"

    if(![System.IO.Directory]::Exists($MainReportFilePath)){
        #Main Report File Doesn't Exist
        New-Item -Path "$env:USERPROFILE\Desktop\" -Name "ADMIN_REPORTS" -ItemType Directory -Force
    }

    if(![System.IO.Directory]::Exists($ReportFilePath)){
        #Report File Doesn't Exist
        New-Item -Path "$MainReportFilePath" -Name "$ReportFileName" -ItemType Directory -Force
    }
    
}

Report_File


function Subnet_Ping{
<#
Subnet_Ping is a tool that allows you to select the first three octets of an IP to ping
everything in that subnet. It will then take this data and record it to a CSV file to 
view at a later time. 
#>
    #Input the Octet Information
    $1stOctet = Read-Host "Enter the first Octet of the IP Address"
    $2ndOctet = Read-Host "Enter the second Octet of the IP Address"
    $3rdOctet = Read-Host "Enter the third Octet of the IP Address"
    $IP = "$1stOctet.$2ndOctet.$3rdOctet"

    #Building the Automatic name of the report to be saved
    $DailyFileName = Get-Date -Format "(dd-MMM-yyyy)REPORTS"
    $ScanFileName = Get-Date -Format "'PING_REPORT(SUBNET $IP.0)_'ddMMMyy(hhmmsstt).CSV'"
    $DailyFilePath = "$env:USERPROFILE\Desktop\ADMIN_REPORTS\$DailyFIleName\$ScanFileName"

    #The command theat will then 

}
