# allow script execution for current user:
#   set-executionpolicy -force -scope currentuser remotesigned

$net_profile = join-path -path (split-path $MyInvocation.MyCommand.Path -parent) -childpath "profile.ps1"
$local_profile = join-path -path ([environment]::getfolderpath("mydocuments")) -childpath "WindowsPowerShell\profile.ps1"
new-item -path $local_profile -itemtype "file" -force -value (". " + $net_profile + "`n")

function Pause($message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

function SetKeyRate()
{
    # Based on the following app that lets you set keyboard repeat rate outside the
    # ranges allowed in the Windows UI:
    #
    #   https://geekhack.org/index.php?topic=41881.0
    #   https://www.reddit.com/r/AllThingsTerran/comments/54z257/hotkey_users_improve_keyboard_repeat_rate_and/
    #
    # ...which has MFC code that boils down to this, in C# because:
    $code = @'
        [DllImport("user32.dll", SetLastError = false)]
        internal static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref FILTERKEYS pvParam, uint fWinIni);
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        internal struct FILTERKEYS
        {
            public uint cbSize;
            public uint dwFlags;
            public uint iWaitMSec;
            public uint iDelayMSec;
            public uint iRepeatMSec;
            public uint iBounceMSec;
        }
        const uint SPI_SETFILTERKEYS = 0x0033;
        const uint SPIF_UPDATEINIFILE = 0x01;
        const uint SPIF_SENDCHANGE = 0x02;
        const uint FKF_FILTERKEYSON = 0x00000001;
        const uint FKF_AVAILABLE = 0x00000002;
        const uint FKF_CONFIRMHOTKEY = 0x00000008;
        const uint FKF_HOTKEYSOUND = 0x00000010;
        const uint FKF_INDICATOR = 0x00000020;
        public static void SetKeyRate()
        {
            FILTERKEYS fk = new FILTERKEYS();
            fk.cbSize = (uint)Marshal.SizeOf(fk);
            fk.dwFlags = FKF_FILTERKEYSON | FKF_AVAILABLE | FKF_CONFIRMHOTKEY | FKF_HOTKEYSOUND | FKF_INDICATOR;
            fk.iWaitMSec = 0;
            fk.iDelayMSec = 250;
            fk.iRepeatMSec = 20;
            fk.iBounceMSec = 0;
            uint winini = SPIF_UPDATEINIFILE | SPIF_SENDCHANGE;
            if (!SystemParametersInfo(SPI_SETFILTERKEYS, fk.cbSize, ref fk, winini))
            {
                Console.WriteLine("System call failed.\nUnable to set keyrate.");
            }
        }
'@
    Add-Type -MemberDefinition $code -Name SetKeyRateUtil -Namespace Throwaway
    [Throwaway.SetKeyRateUtil]::SetKeyRate()
}

function EnsureKey($path)
{
    if (!(Test-Path $path))
    {
        New-Item -Path $path -Force | Out-Null
    }
}

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "Setup environment"
function PrefixPath([string] $name, [string] $path, [string] $target)
{
    $escapedPath = [regex]::Escape($path)
    $existingValueParts = [Environment]::GetEnvironmentVariable($name, $target) -split ';'
    foreach ($part in $existingValueParts)
    {
        if ($part -match "^$escapedPath\\?")
        {
            return
        }
    }
    $newValue = (@($path) + $existingValueParts) -join ';'
    [Environment]::SetEnvironmentVariable($name, $newValue, $target)
}
[Environment]::SetEnvironmentVariable("DIRCMD", "/A /OGN", "User")
[Environment]::SetEnvironmentVariable("PYTHONDONTWRITEBYTECODE", "1", "User")
[Environment]::SetEnvironmentVariable("PIP_REQUIRE_VIRTUALENV", "true", "User")
PrefixPath "PATH" "G:\My Drive\bin" "User"

Write-Host "Remap CapsLock"
$mapCapsLockToLeftCtrl = [byte[]](00,00,00,00,00,00,00,00,0x02,00,00,00,0x1D,00,0x3A,00,00,00,00,00)
New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "Scancode Map" -PropertyType "Binary" -Value $mapCapsLockToLeftCtrl -Force

Write-Host "Enabling short keyboard delay..."
New-ItemProperty "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0 -Force

Write-Host "Setting key rate via filter keys..."
SetKeyRate

Write-Host "Disabling Sticky keys prompt..."
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"

Write-Host "Disable Shake"
$path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
EnsureKey($path)
Set-ItemProperty -Path $path -Name "NoWindowMinimizingShortcuts" -Type DWord -Value 1

Write-Host "Explorer Settings"
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $path -Name "DontPrettyPath" -Type DWord -Value 0
Set-ItemProperty -Path $path -Name "Hidden" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "HideFileExt" -Type DWord -Value 0
Set-ItemProperty -Path $path -Name "HideIcons" -Type DWord -Value 0
Set-ItemProperty -Path $path -Name "HideMergeConflicts" -Type DWord -Value 0
Set-ItemProperty -Path $path -Name "NavPaneExpandToCurrentFolder" -Type DWord -Value 1
# Win11 22H2 broke quick access reordering, and disabling this seems to fix it.  Found via comments in https://archive.ph/HGYOw
# Set-ItemProperty -Path $path -Name "NavPaneShowAllFolders" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "ShowInfoTip" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "ShowStatusBar" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "ShowSuperHidden" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "TaskbarAl" -Type DWord -Value 0
# These no longer works in Win11 22H2
# Set-ItemProperty -Path $path -Name "TaskbarSi" -Type DWord -Value 0
# Set-ItemProperty -Path $path -Name "TaskbarSmallIcons" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "UseCompactMode" -Type DWord -Value 1

Write-Host "Disabling advertisements"
# Sync provider notifications in File Explorer
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
# Get fun facts, tips, tricks, and more on your lock screen
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
# Show suggested content in Settings app
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
# Get tips and suggestions when using Windows
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
# Suggest ways to get the most out of Windows and finish setting up this device
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
# Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what's new and suggested
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
# Let apps show me personalized ads by using my advertising ID
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
# Tailored experiences
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
# "Show recommendations for tips, shortcuts, new apps, and more" on Start
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0

Write-Host "Beta: Use Unicode UTF-8 for worldwide language support"
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage"
Set-ItemProperty -Path $path -Name "ACP" -Type String -Value "65001"
Set-ItemProperty -Path $path -Name "OEMCP" -Type String -Value "65001"
Set-ItemProperty -Path $path -Name "MACCP" -Type String -Value "65001"

Write-Host "Enabling fast menu fly-outs..."
New-ItemProperty "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0 -Force

$internal_setup_path = join-path -path $PSScriptRoot -childpath "..\internal\initial_setup.ps1"
if (Test-Path $internal_setup_path -PathType Leaf) {
    . $internal_setup_path
}

Write-Host "Sublime right-click menu"
$path = "HKCU:\Software\Classes\*\shell\Open with Sublime Text\command"
EnsureKey($path)
Set-Item -Path $path -Value 'C:\Program Files\Sublime Text\sublime_text.exe "%1"'

Write-Host "Enable old-style context menus"
$path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
EnsureKey($path)
Set-Item -Path $path -Value ""

Write-Host "Restarting Explorer"
Stop-Process -Name explorer -Force

Write-Host "Photoshop CS6 overscroll panning"
$path = "HKEY_CURRENT_USER\Software\Adobe\Photoshop\60.0"
EnsureKey($path)
Set-ItemProperty -Path $path -Name "ExtraOverscrolling" -Type DWord -Value 2

$install_apps_path = join-path -path $PSScriptRoot -childpath "install_apps.ps1"
if (Test-Path $install_apps_path -PathType Leaf) {
    . $install_apps_path
}

Pause("press any key...")
