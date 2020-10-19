[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Target ip address")]
    [string] $Target,
    [Parameter(Mandatory = $false, HelpMessage = "Target ip addresses list")]
    [string] $File,
    [Parameter(Mandatory = $true, HelpMessage = "Target port")]
    [int] $Port,
    [Parameter(Mandatory = $false, HelpMessage = "Log file")]
    [string] $Output,
    [Parameter(Mandatory = $false, HelpMessage = "Interval time")]
    [int] $Interval = 60
)

function TcpConnect($ip, $port) {
    $result = $false
    try {
        $TcpClient = New-Object Net.Sockets.TcpClient
        $TcpClient.Connect($ip, $port)
        if ($TcpClient.Connected) {
            $result = $true
        }
        $TcpClient.Close()
    }
    catch [System.Net.Sockets.SocketException] {
        # Port is closed.
    }
    return $result
}

function PortScan {
    if ([string]::IsNullOrEmpty($Target) -and [string]::IsNullOrEmpty($File)) {
        Write-Error Error1
        break
    }

    if ((-not [string]::IsNullOrEmpty($Target)) -and (-not [string]::IsNullOrEmpty($File))) {
        Write-Error Error2
        break
    }

    if (-not [string]::IsNullOrEmpty($Target)) {
        if (TcpConnect $Target $Port) {
            Write-Output "Port is open."
        } else {
            Write-Output "Port is closed."
        }
    }

    if (-not [string]::IsNullOrEmpty($File)) {
        $log = (-not [string]::IsNullOrEmpty($Output))
        if ($log) {
            $date = Get-Date -Format G
            "-----" | Out-File -FilePath $Output -Encoding utf8
            "Starting PortScaner at $date" | Out-File -FilePath $Output -Encoding utf8 -Append
            "Target port: $Port" | Out-File -FilePath $Output -Encoding utf8 -Append
            "-----" | Out-File -FilePath $Output -Encoding utf8 -Append
        }
        $ips = Get-Content $File
        foreach ($ip in $ips) {
            if (TcpConnect $Target $Port) {
                Write-Output $ip
                if ($log) {
                    $ip | Out-File -FilePath $Output -Encoding utf8 -Append
                }
            } else {
                # Port is closed.
            }
            Start-Sleep -Seconds $Interval
        }
    }
}

PortScan