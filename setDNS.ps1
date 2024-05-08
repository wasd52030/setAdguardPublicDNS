param (
    $type
)

# 檢查是否已經以 Administrator 身份執行
function CheckAdministrator {
    $context = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $context.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $scriptPath = $MyInvocation.ScriptName
        $process = New-Object System.Diagnostics.ProcessStartInfo
        $process.FileName = "powershell.exe"
        $process.Arguments = "-File `"$scriptPath`" -type $type"
        $process.Verb = "runas"
        [System.Diagnostics.Process]::Start($process) | Out-Null
        Exit
    }
}

function SetDNSAddresses {
    Get-NetIPInterface | Where-Object {
        $IPInterfaceId = $_.InterfaceIndex

        $ip4Preferred = "94.140.14.14"
        $ip4Alternate = "94.140.15.15"
        Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ServerAddresses $ip4Preferred, $ip4Alternate

        $ip6Preferred = "2a10:50c0::ad1:ff"
        $ip6Alternate = "2a10:50c0::ad2:ff"
        Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ServerAddresses $ip6Preferred, $ip6Alternate
    }
}

function ResetDNSAddresses {
    Get-NetIPInterface | Where-Object {
        $IPInterfaceId = $_.InterfaceIndex

        Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ResetServerAddresses
        Set-DnsClientServerAddress -InterfaceIndex $IPInterfaceId -ResetServerAddresses
    }
}

CheckAdministrator

if ($type -eq "set") {
    SetDNSAddresses
} elseif ($type -eq "reset") {
    ResetDNSAddresses
}

ipconfig /release
ipconfig /flushdns
ipconfig /registerdns
ipconfig /renew