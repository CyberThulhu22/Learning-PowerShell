function Menu_Selection{
    
    Read-Host "Type your selection and press Enter: "

}

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

function Save_Report{
    Write-Host "PASS"  

}


function Main{
do {
$Host_PcName = hostname
Clear-Host
Write-Host "/////////////// Administrator Tools //////////////"
Write-Host "=================================================="
Write-Host "      Currently on Computer: $Host_PcName         "
Write-Host "      Current User: $env:USERPROFILE              "
Write-Host "=================================================="
Write-Host "                                                  "
Write-Host "1. PC PINGING TOOL                                "
Write-Host "2. FILE SEARCHING TOOL                            "
Write-Host "3. FILE DELETING TOOL                             "
Write-Host "                                                  "
Write-Host "--------------------------------------------------"
Write-Host "H. Help                                           "
Write-Host "X. Exit                                           "
Write-Host "--------------------------------------------------"
Write-Host "=================================================="
Write-Host "                                                  "
$choice = Menu_Selection

$ok = @('1', '2', '3', 'H', 'X') -contains $choice
if(-not $ok){
    Write-Host "Invalid Selection"}
}
until ($ok)

switch ( $choice ){
    
    "1" {
        do{
            Clear-Host
            Write-Host "=============================="
            Write-Host ">>>>>> PC PINGING TOOL <<<<<<<"
            Write-Host "=============================="
            Write-Host "                              "
            Write-Host "1. Ping a Computer?           "
            Write-Host "2. Ping a List of Computers?  "
            Write-Host "B. Go Back to Previous Menu.  "
            Write-Host "                              "
            Write-Host "------------------------------"
            Write-Host "=============================="
            $choice = Menu_Selection

            $ok = @('1', '2', 'B') -contains $choice
            if(-not $ok){
                Write-Host "Invalid Selection"
            }

        }
        until($ok)

        switch( $choice ){
            '1'{
                Clear-Host
                $ComputerName = Read-Host "Input the name of the Computer"
                Write-Host "--------------------"
                Write-Host "Pinging $ComputerName"
                Ping $ComputerName
                Write-Host "--------------------"

            }

            '2'{
                Clear-Host
                Write-Host "Pinging Selection 2"
            }

            'B'{
                break
            }
        }

    }

    '2'{
    
    }

    '3'{
    
    }

    'H'{
    
    }
    
    'X'{
    
    }

}
}

Main