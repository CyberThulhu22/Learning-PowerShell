function Ping-ComputerList_Style1{
    try{

    $ComputerList = (Get-Content "C:\Users\CyberThulhu22\Desktop\ComputerList.txt")
    
        ForEach($pc in $ComputerList){

            if(Test-Connection -ComputerName $pc -Count 1){
                Write-Host "$pc is up" -BackgroundColor Green
            }else{
                Write-Host "$pc is down" -BackgroundColor Red
            }

            Start-Sleep(2)

        }

    }catch{
        Write-Host "This code failed"
    }
#End of Function
}

function Ping-ComputerList_Style2{
    Get-Content "C:\Users\CyberThulhu22\Desktop\ComputerList.txt" | ForEach-Object {
        If(Test-Connection $_ -Quiet -Count 1){
            Write-Host "$_ is UP" -b Green
        }
        Else{
            Write-Host "$_ is DOWN" -b Red
        }
    }
}

Ping-ComputerList_Style2