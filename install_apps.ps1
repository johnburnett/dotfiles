Set-StrictMode -Version 3.0

$pkgInfos = @(
    @{'selfUpdates'=$false; 'id'='Microsoft.WindowsTerminal'}
    @{'selfUpdates'=$false; 'id'='Microsoft.PowerShell'}
    @{'selfUpdates'=$true;  'id'='SublimeHQ.SublimeText.4.Dev'}
    @{'selfUpdates'=$true;  'id'='SublimeHQ.SublimeMerge.Dev'}
    @{'selfUpdates'=$true;  'id'='Obsidian.Obsidian'}
    @{'selfUpdates'=$false; 'id'='voidtools.Everything'}
    @{'selfUpdates'=$true;  'id'='Google.GoogleDrive'}
    @{'selfUpdates'=$false; 'id'='Rclone.Rclone'}
    @{'selfUpdates'=$false; 'id'='7zip.7zip'}
    @{'selfUpdates'=$true;  'id'='Microsoft.PowerToys'}

    @{'selfUpdates'=$true;  'id'='Vivaldi.Vivaldi'}
    @{'selfUpdates'=$true;  'id'='Mozilla.Firefox'}
    @{'selfUpdates'=$true;  'id'='Google.Chrome'}

    @{'selfUpdates'=$true;  'id'='Beeper.Beeper'}
    @{'selfUpdates'=$true;  'id'='OpenWhisperSystems.Signal'}
    @{'selfUpdates'=$true;  'id'='Zoom.Zoom'}
    @{'selfUpdates'=$true;  'id'='Discord.Discord'}

    @{'selfUpdates'=$true;  'id'='Valve.Steam'}
    @{'selfUpdates'=$true;  'id'='EpicGames.EpicGamesLauncher'}
    @{'selfUpdates'=$true;  'id'='ElectronicArts.EADesktop'}
    @{'selfUpdates'=$true;  'id'='Ubisoft.Connect'}

    @{'selfUpdates'=$false; 'id'='Git.Git'}
    @{'selfUpdates'=$true;  'id'='TortoiseGit.TortoiseGit'}
    @{'selfUpdates'=$false; 'id'='Mercurial.Mercurial'}
    @{'selfUpdates'=$false; 'id'='Slik.Subversion'}
    @{'selfUpdates'=$true;  'id'='Araxis.Merge'}
    @{'selfUpdates'=$false; 'id'='Python.Python.3.12'}
    @{'selfUpdates'=$false; 'id'='OpenJS.NodeJS'}
    @{'selfUpdates'=$false; 'id'='Kitware.CMake'}
    @{'selfUpdates'=$true;  'id'='Microsoft.VisualStudio.2022.Community'}
    @{'selfUpdates'=$false; 'id'='GoLang.Go'}

    @{'selfUpdates'=$false; 'id'='evsar3.sshfs-win-manager'}
    @{'selfUpdates'=$true;  'id'='NordSecurity.NordVPN'}
    @{'selfUpdates'=$false; 'id'='qBittorrent.qBittorrent'}

    @{'selfUpdates'=$false; 'id'='Audacity.Audacity'}
    @{'selfUpdates'=$false; 'id'='BlenderFoundation.Blender'}
    @{'selfUpdates'=$false; 'id'='ImageMagick.ImageMagick'}
    @{'selfUpdates'=$true;  'id'='VideoLAN.VLC'}
    @{'selfUpdates'=$false; 'id'='FFmpeg'}
    @{'selfUpdates'=$false; 'id'='OliverBetz.ExifTool'}
)

function Load-Module ($moduleName) {
    # https://stackoverflow.com/a/51692402
    if (!(Get-Module | Where-Object {$_.Name -eq $moduleName})) {
        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $moduleName}) {
            Import-Module $moduleName
        } else {
            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $moduleName | Where-Object {$_.Name -eq $moduleName}) {
                Install-Module -Name $moduleName -Force -Scope AllUsers
                Import-Module $moduleName
            } else {
                # If the module is not imported, not available and not in the online gallery then abort
                Write-Host "Module $moduleName not imported, not available and not in an online gallery, exiting."
                exit 1
            }
        }
    }
}

Load-Module 'Microsoft.Winget.Client'
# (Get-Module Microsoft.Winget.Client).ExportedCommands

function Pause($message)
{
    # Check if running Powershell ISE
    if ((Test-Path Variable:Global:psISE) -and $psISE)
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

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Commands to set system into a state where rclone needs to be
# installed, and 7zip needs to be upgraded.  Useful for testing.
# Uninstall-WinGetPackage -Query Rclone.Rclone; winget uninstall --all-versions --silent --accept-source-agreements --query 7zip.7zip; Install-WinGetPackage -Mode Silent -Scope System -MatchOption Equals -Version 23.01 -Id 7zip.7zip

$sharedInstallUpgradeArgs = @{
    'Mode'='Silent'
    'Scope'='System'
    'MatchOption'='Equals'
}
$rebootRequired = $false
foreach ($pkgInfo in $pkgInfos)
{
    # Find-WinGetPackage -Id $pkgInfo.id -MatchOption Equals
    $pkg = Get-WinGetPackage -MatchOption Equals -Query $pkgInfo.id
    if ($pkg)
    {
        if ($pkgInfo.selfUpdates)
        {
            Write-Host -ForegroundColor 'Gray' 'Skipping self-updating' $pkgInfo.id
        } elseif ($pkg.IsUpdateAvailable) {
            Write-Host -ForegroundColor 'Blue' 'Upgrading' $pkgInfo.id
            $args = $sharedInstallUpgradeArgs.Clone()
            $args['Query'] = $pkgInfo.id
            $result = Update-WinGetPackage @args
            $rebootRequired = $rebootRequired -or $result.RebootRequired
        } else {
            Write-Host -ForegroundColor 'Gray' 'Up to date' $pkgInfo.id
        }
    } else {
        Write-Host -ForegroundColor 'Green' 'Installing' $pkgInfo.id
        $args = $sharedInstallUpgradeArgs.Clone()
        $args['Query'] = $pkgInfo.id
        $result = Install-WinGetPackage @args
        $rebootRequired = $rebootRequired -or $result.RebootRequired
    }
}

if ($rebootRequired) {
    Write-Host -ForegroundColor 'Red' 'Reboot is required'
}

Pause("press any key...")
