# allow script execution for current user:
#   set-executionpolicy -force -scope currentuser remotesigned

$net_profile = join-path -path (split-path $MyInvocation.MyCommand.Path -parent) -childpath "profile.ps1"
$local_profile = join-path -path ([environment]::getfolderpath("mydocuments")) -childpath "WindowsPowerShell\profile.ps1"
new-item -path $local_profile -itemtype "file" -force -value (". " + $net_profile + "`n")

function set_user_var($name, $value) {
    [Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
}

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "Setup environment"
[Environment]::SetEnvironmentVariable("DIRCMD", "/A /OGN", "User")
[Environment]::SetEnvironmentVariable("PYTHONDONTWRITEBYTECODE", "1", "User")

Write-Host "Remap CapsLock"
$mapCapsLockToLeftCtrl = [byte[]](00,00,00,00,00,00,00,00,0x02,00,00,00,0x1D,00,0x3A,00,00,00,00,00)
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "Scancode Map" -PropertyType "Binary" -Value $mapCapsLockToLeftCtrl -Force

Write-Host "Enabling short keyboard delay..."
New-ItemProperty "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0 -Force

Write-Host "Disabling Sticky keys prompt..."
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"

Write-Host "Disable Shake"
$path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path $path))
{
    New-Item -Path $path -Force | Out-Null
}
Set-ItemProperty -Path $path -Name "NoWindowMinimizingShortcuts" -Type DWord -Value 1

Write-Host "Disable Thumbs.db"
$path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer\Advanced"
if (!(Test-Path $path))
{
    New-Item -Path $path -Force | Out-Null
}
Set-ItemProperty -Path $path -Name "DisableThumbnailCache" -Type DWord -Value 1

Write-Host "Enabling fast menu fly-outs..."
New-ItemProperty "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0 -Force

$internal_setup_path = join-path -path $PSScriptRoot -childpath "..\internal\initial_setup.ps1"
if (Test-Path $internal_setup_path -PathType Leaf) {
    . $internal_setup_path
}
