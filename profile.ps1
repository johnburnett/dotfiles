$host.ui.rawui.backgroundcolor = "black"
clear-host

$_profile_sw = [Diagnostics.Stopwatch]::StartNew()
$_profile_prevstamp = $_profile_sw.elapsed.totalseconds
$_profile_do_debug_print = $false

function _profile_debug_print($msg) {
    if ($_profile_do_debug_print) {
        if ($msg -eq "") {
            write-host -nonewline ""
        } else {
            write-host $msg
        }
    }
}

function _profile_stamp($label) {
    $now = $_profile_sw.elapsed.totalseconds
    if ($_profile_do_debug_print) {
        _profile_debug_print("{0}: {1:f3}s" -f $label, ($now - $_profile_prevstamp))
    }
    $script:_profile_prevstamp = $now
}
# Weirdness... second function call sinks 0.2 seconds?  Without this, that cost
# gets bundled into the first legitimate _profile_stamp call below.  No idea.
_profile_stamp ""; _profile_stamp ""

set-psreadlineoption -HistoryNoDuplicates:$true
set-psreadlineoption -HistorySearchCursorMovesToEnd:$true
set-psreadlineoption -ExtraPromptLineCount:1
set-psreadlineoption -AddToHistoryHandler {
    Param([string]$line)
    return ($line -notmatch "^ls$|^dir$|^exit$|^f$")
}
_profile_stamp "psreadlineoption"

function Prompt {
    write-host $executionContext.SessionState.Path.CurrentLocation -foregroundcolor "cyan"
    write-host "$(&{if($LASTEXITCODE) {$LASTEXITCODE} else {"0"}}) " -foregroundcolor "yellow" -nonewline
    write-host "[$env:USERNAME@$env:COMPUTERNAME]" -foregroundcolor "magenta" -nonewline
    return "$('>' * ($nestedPromptLevel + 1)) "
}
_profile_stamp "prompt"

function _profile_spawn($progchildpath, $arglist) {
    $pargs = @{
        'filepath' = join-path -path ${env:ProgramFiles} -childpath $progchildpath
    }
    # -argumentlist arg doesn't accept null or empty lists prior to v6.1.
    # See https://github.com/PowerShell/PowerShell/issues/4520
    if ($arglist.count) {
        $pargs.argumentlist = $arglist
    }
    start-process @pargs
}

################################################################################
# Aliases

rm alias:ls

################################################################################
# Functions

function blb { bl -p=build $args }
function blgit { bl -p=build blgit $args }
function devenv {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    pushd (join-path -path ${env:ProgramFiles(x86)} -childpath "Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build")
    cmd /c "vcvarsall.bat x64 & set" |
    foreach {
      if ($_ -match "=") {
        $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
      }
    }
    popd
    $sw.stop()
    write-host ("`nVisual Studio 2017 Command Prompt variables set ({0:f3}s)." -f $sw.elapsed.totalseconds)
}
function dif { _profile_spawn "Araxis\Araxis Merge\Merge.exe" $args }
function f { start-process . }
function ls { Get-ChildItem @args | Sort-Object -Property name }
function la { Get-ChildItem -Force @args | Sort-Object -Property name }
function rmf { Remove-Item -Recurse -Force @args }
function st { _profile_spawn "Sublime Text 3\sublime_text.exe" $args }
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
_profile_stamp "functions"

################################################################################

$_profile_internal_path = join-path -path $PSScriptRoot -childpath "..\internal\profile.ps1"
if (Test-Path $_profile_internal_path -PathType Leaf) {
    . $_profile_internal_path
}
_profile_stamp "internal profile"

_profile_debug_print("{0} took {1:f3}s" -f $PSCommandPath, $_profile_sw.elapsed.totalseconds)
