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

function List-Ping{

    Report_File
    Clear
    $ReportFileName = Get-Date -Format "'Reports'(dd-MMM-yyyy)"
    $ListFileName = Read-Host "Type the name of the Computer List on your Desktop:"
    $ComputerList = Get-Content -Path "$env:USERPROFILE\Desktop\$ListFileName" -Force
    $PingListReport = Get-Date -Format "'PING REPORT_'ddMMMyyyy(hhmmtt).CSV"
    Clear
    Foreach($PC in $ComputerList){
        if(Test-Connection -ComputerName $PC -Count 1){

            $TestConnect = Test-Connection -ComputerName $PC -Count 1 -ErrorAction SilentlyContinue
            Write-Host "Testing Connection to $PC and writing to $PingListReport"
            $TestConnect | Export-Csv -Path "$env:USERPROFILE\Desktop\ADMIN_REPORTS\$ReportFileName\$PingListReport" -Append -Encoding ASCII -Force
        
        }else{
            $FailPing = "Cannot connect to $PC"
            Write-Host $FailPing
            $FailPing | Export-Csv -Path "$env:USERPROFILE\Desktop\ADMIN_REPORTS\$ReportFileName\$PingListReport" -Append -Encoding ASCII -Force
        }
    
    }

}

List-Ping