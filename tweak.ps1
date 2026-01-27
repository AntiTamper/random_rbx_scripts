$n=(([guid]::NewGuid().ToString("N"))*4).Substring(0,128)
$p1="HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"
$p2="HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName"
$p3="HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty $p1 ComputerName $n
Set-ItemProperty $p2 ComputerName $n
Set-ItemProperty $p3 HostName $n
Set-ItemProperty $p3 "NV Hostname" $n
