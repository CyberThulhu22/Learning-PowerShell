function Subnet-Ping{
    $ping = New-Object System.Net.NetworkInformation.Ping
    $thrOct = 1..254
    
    ForEach($tOct in $thrOct){
        1..254 | %{ $ping.Send("192.168.$_.$_")} | select address, status
    }
}

function NewSubnet-Ping{

    1..254 | ForEach-Object { New-Object psobject -Property @{Address="192.168.0.$_";Ping=(Test-Connection "192.168.0.$_" -Quiet -Count 1)}}

}

NewSubnet-Ping