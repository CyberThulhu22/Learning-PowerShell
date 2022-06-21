<#
.SYNOPSIS
        Takes and IP Address and Port/Range of Ports and Performs a Port Scan

.DESCRIPTION
        Takes and IP Address and Port/Range of Ports and Performs a Port Scan

.EXAMPLE
        PowerShell-Portscanner.ps1 [[-Address #.#.#.#]|[-Network #.#.#.#/##]|[-IPList '.\ip.lst']] [[-Port #][-PortRange #-#][-PortList '.\ports.lst']] [-TCP|-UDP] [-OutFile '.\out.txt'] [-Verbose]
.NOTES
        NAME:    PS-PortScan.ps1
        VERSION: 1.0.0
        AUTHOR:  Jesse Leverett (CyberThulhu)
        STATUS:  Mostly Complete
        TO-DO:   Finish Cleaning Script

        COPYRIGHT © 2022 Jesse Leverett
#>

Function Get-SubnetAddresses {
    <#
    .SYNOPSIS
            Takes an IP Address/CIDR and Returns Lower/Upper Address to be used in another Function

    .DESCRIPTION
            Takes an IP Address with CIDR Notation and Returns the Subnet Address Lower and Upper IP Address to be used in another function

    .PARAMETER IP
            IP Address

    .PARAMETER maskbits
            CIDR notation

    .EXAMPLE
            Get-SubnetAddresses [-IP X.X.X.X] [-maskbits XX]
    .LINK

    #>
    Param (
        [IPAddress]$IP,
        [ValidateRange(0, 32)]
        [Int]$maskbits
     )

    # Convert the mask to type [IPAddress]:
    $mask = ([Math]::Pow(2, $MaskBits) - 1) * [Math]::Pow(2, (32 - $MaskBits))
    $maskbytes = [BitConverter]::GetBytes([UInt32] $mask)
    $DottedMask = [IPAddress]((3..0 | ForEach-Object { [String] $maskbytes[$_] }) -join '.')

    # bitwise AND them together, and you've got the subnet ID
    $lower = [IPAddress] ( $ip.Address -band $DottedMask.Address )

    # We can do a similar operation for the broadcast address
    # subnet mask bytes need to be inverted and reversed before adding
    $LowerBytes = [BitConverter]::GetBytes([UInt32] $lower.Address)
    [IPAddress]$upper = (0..3 | %{$LowerBytes[$_] + ($maskbytes[(3-$_)] -bxor 255)}) -join '.'

    # Make an object for use Elsewhere
    Return [pscustomobject][ordered]@{
        Lower=$lower
        Upper=$upper
    }
}

Function Get-IPRange {
    <#
    .SYNOPSIS
            Takes Lowest and Highest IP Address in a Network and Returns a List of all IP Address(es)

    .DESCRIPTION
            Takes an IP Networks Lowest and Highest IP Address and Returns a List of all IP Address within that Range

    .PARAMETER lower
            Takes an IP Networks Lowest IP Address

    .PARAMETER upper
            Takes an IP Networks Highest IP Address

    .EXAMPLE
            Get-IPRange [-lower X.X.X.X] [-upper X.X.X.X]

    .LINK
            
    #>
    param (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)][IPAddress]$lower,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)][IPAddress]$upper
    )
    # use lists for speed
    $IPList = [Collections.ArrayList]::new()
    $null = $IPList.Add($lower)
    $i = $lower

    # increment ip until reaching $upper in range
    while ( $i -ne $upper ) { 
        # IP octet values are built back-to-front, so reverse the octet order
        $iBytes = [BitConverter]::GetBytes([UInt32] $i.Address)
        [Array]::Reverse($iBytes)

        # Then we can +1 the Int value and reverse again
        $nextBytes = [BitConverter]::GetBytes([UInt32]([bitconverter]::ToUInt32($iBytes,0) +1))
        [Array]::Reverse($nextBytes)

        # Convert to IP and add to list
        $i = [IPAddress]$nextBytes
        $null = $IPList.Add($i)
    }
    return $IPList
}

Function port-scan-tcp {
    <#
    .SYNOPSIS
            Working Function to Scan for TCP Ports

    .DESCRIPTION
            Worker Function that takes a(n) IP Address(es) and Port(s) and Performs a TCP Scan

    .PARAMETER hosts
            Single/Array of IP Address(es)

    .PARAMETER ports
            Single/Array of Port(s)

    .EXAMPLE
            port-scan-tcp -hosts [x.x.x.x] -ports [x]

    .LINK
            https://raw.githubusercontent.com/InfosecMatter/Minimalistic-offensive-security-tools/master/port-scan-tcp.ps1
    #>
    param($hosts,$ports)
    If (!$ports) {
        Write-Host "usage: port-scan-tcp <host|hosts> <port|ports>"
        Write-Host " e.g.: port-scan-tcp 192.168.1.2 445`n"
        return
    }
    $out = ".\scanresults.txt"
    ForEach($p in [array]$ports) {
        ForEach($h in [array]$hosts) {
            $x = (gc $out -EA SilentlyContinue | select-String "^$h,tcp,$p,")
            If ($x) {
                gc $out | select-String "^$h,tcp,$p,"
                continue
            }
            $msg = "$h,tcp,$p,"
            $t = new-Object system.Net.Sockets.TcpClient
            $c = $t.ConnectAsync($h,$p)
            for($i=0; $i -lt 10; $i++) {
                If ($c.isCompleted) {
                    break
                }
                sleep -milliseconds 100
            }
            $t.Close();
            $r = "Filtered"
            If ($c.isFaulted -and $c.Exception -match "actively refused") {
                $r = "Closed"
            }
            ElseIf ($c.Status -eq "RanToCompletion") {
                $r = "Open"
            }
            $msg += $r
            Write-Host "$msg"
            echo $msg >>$out
        }
    }
}

Function port-scan-udp {
    <#
    .SYNOPSIS
            Working Function to Scan for UDP Ports

    .DESCRIPTION
            Worker Function that takes a(n) IP Address(es) and Port(s) and Performs a UDP Scan
    .PARAMETER hosts
            Single/Array of IP Address(es)

    .PARAMETER ports
            Single/Array of Port(s)

    .EXAMPLE
            port-scan-udp -hosts [x.x.x.x] -ports [x]

    .LINK
            https://raw.githubusercontent.com/InfosecMatter/Minimalistic-offensive-security-tools/master/port-scan-udp.ps1
    #>

    param($hosts,$ports)
    If (!$ports) {
        Write-Host "usage: port-scan-udp <host|hosts> <port|ports>"
        Write-Host " e.g.: port-scan-udp 192.168.1.2 445`n"
        return
    }
    $out = ".\scanresults.txt"
    ForEach($p in [array]$ports) {
    ForEach($h in [array]$hosts) {
        $x = (gc $out -EA SilentlyContinue | select-String "^$h,udp,$p,")
        If ($x) {
            gc $out | select-String "^$h,udp,$p,"
            continue
        } # END If
    $msg = "$h,udp,$p,"
    $u = new-object system.net.sockets.udpclient
    $u.Client.ReceiveTimeout = 500
    $u.Connect($h,$p)
    # Send a single byte 0x01
    [void]$u.Send(1,1)
    $l = new-object system.net.ipendpoInt([system.net.ipaddress]::Any,0)
    $r = "Filtered"
        Try {
            If ($u.Receive([ref]$l)) {
                # We have received some UDP data from the remote host in return
                $r = "Open"
            } # END If
        } # END Try
        Catch {
            If ($Error[0].ToString() -match "failed to respond") {
                # We haven't received any UDP data from the remote host in return
                # Let's see If we can ICMP ping the remote host
                If ((Get-wmiobject win32_pingstatus -Filter "address = '$h' and Timeout=1000 and ResolveAddressNames=false").StatusCode -eq 0) {
                    # We can ping the remote host, so we can assume that ICMP is not
                    # filtered. And because we didn't receive ICMP port-unreachable before,
                    # we can assume that the remote UDP port is open
                    $r = "Open"
                } # END If
            } # END If
            ElseIf ($Error[0].ToString() -match "forcibly closed") {
                # We have received ICMP port-unreachable, the UDP port is closed
                $r = "Closed"
            } # END ElseIf
        } # END Catch
        $u.Close()
        $msg += $r
        Write-Host "$msg"
        echo $msg >>$out
        } # END ForEach
    } # END ForEach
} # END port-scan-udp

function Run-PortScan {
    <#
    .SYNOPSIS
            Runs a Port Scan against IP Address(es) and Port(s)

    .DESCRIPTION
            Script that takes a Single IP Address, a IP Network (Using CIDR Notation; Format: X.X.X.X/XX), or a Text Document List of IP Address
            Script also takes a Single Port, a Range of Ports (Format: #-#), or a Text Document List of Port(s)
            Lastly, there is a Switch to target TCP or UDP Transport Protocol or enable Both (-TCP | -UDP | -TCP -UDP )

    .PARAMETER Address
            Quoted String of an IP Address (Format: "X.X.X.X")

    .PARAMETER Network
            Quoted String of an IP Network (Format: "X.X.X.X/XX")

    .PARAMETER IPList
            Path to Text Document with IP Address (Per Line) in a list (Format: .\Path\To\IPList.txt)

    .PARAMETER Port
            Interger of a Port (Format: X)

    .PARAMETER PortRange
            Quoted range of Ports. Comma Deliminated or Range seperated by a dash (-) (Format: "X,X-X")

    .PARAMETER PortList
            Path to Text Document with Ports (Per Line) in a list (Format: .\Path\To\PortList.txt)

    .PARAMETER TCP
            Switch to Enable TCP Scanning

    .PARAMETER UDP
            Switch to Enable UDP Scanning

    .INPUTS

    .OUTPUTS

    .EXAMPLE
            Run-PortScan [[-Address X.X.X.X]|[-Network X.X.X.X/XX]|[-IPList '.\IpList.txt']] [[-Port X]|[-PortRange 'X,X-X']|[-PortList '.\PortList.txt']] [-TCP|-UDP]
    .LINK

    .NOTES

    #>
    [CmdletBinding(DefaultParameterSetName = "default")]
    # GROUP IP
    param(

        [Parameter(ParameterSetName = "Address")]
        [Parameter(Mandatory, ParameterSetName = "Address_Port")]
        [Parameter(Mandatory, ParameterSetName = "Address_PortRange")]
        [Parameter(Mandatory, ParameterSetName = "Address_PortList")]
        [String]$Address,

        [Parameter(ParameterSetName = "Network")]
        [Parameter(Mandatory, ParameterSetName = "Network_Port")]
        [Parameter(Mandatory, ParameterSetName = "Network_PortRange")]
        [Parameter(Mandatory, ParameterSetName = "Network_PortList")]
        [String]$Network,

        [Parameter(ParameterSetName = "IPList")]
        [Parameter(Mandatory, ParameterSetName = "IPList_Port")]
        [Parameter(Mandatory, ParameterSetName = "IPList_PortRange")]
        [Parameter(Mandatory, ParameterSetName = "IPList_PortList")]
        [String]$IPList,

        # GROUP PORT
        [Parameter(ParameterSetName = "Port")]
        [Parameter(Mandatory, ParameterSetName = "Address_Port")]
        [Parameter(Mandatory, ParameterSetName = "Network_Port")]
        [Parameter(Mandatory, ParameterSetName = "IPList_Port")]
        [Int]$Port,

        [Parameter(ParameterSetName = "PortRange")]
        [Parameter(Mandatory, ParameterSetName = "Address_PortRange")]
        [Parameter(Mandatory, ParameterSetName = "Network_PortRange")]
        [Parameter(Mandatory, ParameterSetName = "IPList_PortRange")]
        [String]$PortRange,

        [Parameter(ParameterSetName = "PortList")]
        [Parameter(Mandatory, ParameterSetName = "Address_PortList")]
        [Parameter(Mandatory, ParameterSetName = "Network_PortList")]
        [Parameter(Mandatory, ParameterSetName = "IPList_PortList")]
        [String]$PortList,

        # TCP/UDP Switches
        [Parameter()]
        [Switch]$TCP = $false,

        [Parameter()]
        [Switch]$UDP = $false
    ) # END param

    #"ParameterSetName is {0}" -f $PSCmdlet.ParameterSetName # TROUBLESHOOTING

    # IP GROUP ARGUMENTS
    If ($Address) {
        $MAIN_ADDRESS_ARRAY = @()
        $MAIN_ADDRESS_ARRAY = [String]$Address
    } # END IF (ADDRESS)

    ElseIf ($Network) {
        $MAIN_ADDRESS_ARRAY = @()
        If($Network.Contains('/') -eq $true){
            $addr = [String]$Network.Split('/')[0]
            $mask = [Int]$Network.Split('/')[1]
            ForEach ($ipaddr in (Get-SubnetAddresses -IP $addr -maskbits $mask | Get-IPRange | Select -ExpandProperty IPAddressToString)){
                $MAIN_ADDRESS_ARRAY += [String]$ipaddr
            } # End ForEach

        } # END If
    } # END ElseIf (NETWORK)

    ElseIf ($IPList) {
        $MAIN_ADDRESS_ARRAY = @()
        ForEach($ipaddr in (Get-Content $IPList)){
            $MAIN_ADDRESS_ARRAY += [String]$ipaddr        
        }
    } # END ElseIf (IPLIST)

    # PORT GROUP ARGUMENTS
    If ($Port) {
        $MAIN_PORT_ARRAY = @()
        $MAIN_PORT_ARRAY += [Int]$Port
    } # END IF (PORT)

    ElseIf ($PortRange) {
        $MAIN_PORT_ARRAY = @()
        $PortRangeArray = @()
            
        If($PortRange.Contains(',') -eq $true){
            ForEach($idx in $PortRange.Split(",")){
                $PortRangeArray += "$idx"
            } # END ForEach
            ForEach($idx in $PortRangeArray){
                If([String]$idx.contains("-") -eq $true){
                    ForEach ($nidx in ($idx.split('-')[0]..$idx.split('-')[1])){
                        $MAIN_PORT_ARRAY += [Int]$nidx
                    } # END ForEach
                } # END If
                Else{
                    $MAIN_PORT_ARRAY += [Int]$idx
                } # END Else
            } #END ForEach
        } # END If
        Else{
            If([String]$PortRange.Contains("-") -eq $true){
                ForEach($nidx in ($PortRange.split('-')[0]..$PortRange.split('-')[1])){
                    $MAIN_PORT_ARRAY += [Int]$nidx
                } # END ForEach
            } # END If
            Else{
                $MAIN_PORT_ARRAY += [Int]$PortRange
            } # END Else
        } # END Else
    } # END ElseIf (PORTLIST)

    ElseIf($PortList){
        $MAIN_PORT_ARRAY = @()
        ForEach($listedport in (Get-Content $PortList)){
            $MAIN_PORT_ARRAY += [Int]$listedport
        } # END ForEach
    } # END ElseIf

    #"$MAIN_ADDRESS_ARRAY" # TROUBLESHOOTING
    #"$MAIN_PORT_ARRAY" # TROUBLESHOOTING
    If ($TCP.IsPresent) {
        ForEach($ip_addr in $MAIN_ADDRESS_ARRAY) {
            ForEach($port_num in $MAIN_PORT_ARRAY) {
                port-scan-tcp -hosts $ip_addr -ports $port_num
            } # END ForEach
        } # END ForEach
    } # END If ($TCP.IsPresent())

    If ($UDP.IsPresent) {
        ForEach($ip_addr in $MAIN_ADDRESS_ARRAY) {
            ForEach($port_num in $MAIN_PORT_ARRAY) {
                port-scan-udp -hosts $ip_addr -ports $port_num
            } # END ForEach
        } # END ForEach
    } # END If ($UDP.IsPresent())
}
