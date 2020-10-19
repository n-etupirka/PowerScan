# PowerScan

Simple port scaner with PowerShell

## Usage

Scanning single IP for single port
```
PS C:\> .\PowerScan.ps1 -Target 127.0.0.1 -Port 445
```

Scanning multiple IPs for single port
```
PS C:\> .\PowerScan.ps1 -File .\ip_list.txt -Port 445 -Output portscan_445.log -Interval 60
```