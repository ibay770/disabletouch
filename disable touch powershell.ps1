# Disable Surface Touch Screen and Pen Digitizer Script v3
# Source: https://dancharblog.wordpress.com
# Instructions: Save as a .ps1 file and run it.
# To re-enable, replace "Disable-PnPDevice" with "Enable-PnPDevice".

# Check for administrative privileges
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $myWindowsPrincipal.IsInRole($adminRole)) {
    # Relaunch the script with elevated privileges and bypass execution policy
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell.exe"
    $startInfo.Arguments = $arguments
    $startInfo.Verb = "runas"
    [System.Diagnostics.Process]::Start($startInfo)
    exit
} else {
    $Host.UI.RawUI.WindowTitle = "$($MyInvocation.MyCommand.Definition) (Elevated)"
}

Write-Host "Attempting to disable n-Trig touchscreen/digitizer..."

# Disable all HID-Compliant Touch Screen devices
Get-PnpDevice -FriendlyName "*Touch Screen*" | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false -Verbose
}

# Disable all remaining Surface digitizer-related devices
Get-PnpDevice | Where-Object {
    $_.FriendlyName -match "Digitizer|pen|Surface.*Touch"
} | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false -Verbose
}

# Disable all n-Trig related devices (may be needed for specific Surface models)
Get-PnpDevice -InstanceID 'HID\NTRG*' | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false -Verbose
}

Pause
