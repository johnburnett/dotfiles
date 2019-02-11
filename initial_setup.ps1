# allow script execution for current user:
#   set-executionpolicy -force -scope currentuser remotesigned

$net_profile = join-path -path (split-path $MyInvocation.MyCommand.Path -parent) -childpath "profile.ps1"
$local_profile = join-path -path ([environment]::getfolderpath("mydocuments")) -childpath "WindowsPowerShell\profile.ps1"
new-item -path $local_profile -itemtype "file" -force -value (". " + $net_profile + "`n")

function set_user_var($name, $value) {
    [Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
}

set_user_var "PYTHONDONTWRITEBYTECODE" "1"

. (join-path -path $PSScriptRoot -childpath "..\internal\initial_setup.ps1")
