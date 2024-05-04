$context = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())

# 檢查是否已經以 Administrator 身份執行
if (-not $context.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # 向使用者顯示 UAC 提示，請求 Administrator 權限
    $process = New-Object System.Diagnostics.ProcessStartInfo
    $process.FileName = "powershell.exe" # 使用 PowerShell 可执行文件
    $process.Arguments = "-File `"$($MyInvocation.MyCommand.Path)`"" # 将当前脚本路径作为参数传递给 PowerShell
    $process.Verb = "runas" 
    [System.Diagnostics.Process]::Start($process) | Out-Null
    Exit
}

$q=Get-NetIPInterface | Where-Object {
    $IPInterfaceId=$_.InterfaceIndex
    
    $ip4Preferred="94.140.14.14"
    $ip4Alternate="94.140.15.15"
    Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ServerAddresses $ip4Preferred,$ip4Alternate

    $ip6Preferred="2a10:50c0::ad1:ff"
    $ip6Alternate="2a10:50c0::ad2:ff"
    Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ServerAddresses $ip6Preferred,$ip6Alternate
}

ipconfig /release
ipconfig /flushdns
ipconfig /registerdns
ipconfig /renew