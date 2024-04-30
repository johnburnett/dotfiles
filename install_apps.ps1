$pkgids = @(
    'Microsoft.WindowsTerminal'
    'Microsoft.PowerShell'

    'SublimeHQ.SublimeText.4.Dev'
    'SublimeHQ.SublimeMerge.Dev'
    'Obsidian.Obsidian'

    'voidtools.Everything'
    'Google.GoogleDrive'
    '7zip.7zip'

    'Brave.Brave'
    'Google.Chrome'
    'Mozilla.Firefox'

    'Beeper.Beeper'
    'OpenWhisperSystems.Signal'
    'Zoom.Zoom'
    'Discord.Discord'

    'Valve.Steam'
    'EpicGames.EpicGamesLauncher'
    'ElectronicArts.EADesktop'
    'Ubisoft.Connect'

    'Git.Git'
    'TortoiseGit.TortoiseGit'
    'Slik.Subversion'
    'Araxis.Merge'
    'Python.Python.3.11'
    'OpenJS.NodeJS'
    'Kitware.CMake'
    'Microsoft.VisualStudio.2022.Community'

    'evsar3.sshfs-win-manager'
    'NordSecurity.NordVPN'
    'qBittorrent.qBittorrent'

    'Audacity.Audacity'
    'BlenderFoundation.Blender'
    'ImageMagick.ImageMagick'
    'VideoLAN.VLC'
)

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

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

foreach ( $pkgid in $pkgids )
{
    Write-Host -ForegroundColor 'Green' $pkgid
    # winget list $pkgid || winget install --accept-package-agreements --accept-source-agreements --exact --silent --query $pkgid
    winget install --accept-package-agreements --accept-source-agreements --exact --silent --query $pkgid
}

Pause("press any key...")
