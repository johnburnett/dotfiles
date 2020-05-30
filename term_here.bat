@echo off
setlocal

rem Create shared menu that is referenced by keys below.  Menu has one menu entry per shell.
rem Each entry launches Windows Terminal via wt using the given named profile.  Expects you have
rem corresponding named entries in your profiles.json.

set ROOT_MENU_KEY=HKCU\Software\Classes\Directory\ContextMenus\WindowsTerminalHereMenu
reg delete "%ROOT_MENU_KEY%" /f

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\01cmd
reg add "%ENTRY_KEY%" /v "Icon" /f /d "imageres.dll,-5323"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "cmd"
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\" -p \"cmd\" -d \"%%V\""

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\02git_bash
reg add "%ENTRY_KEY%" /v "Icon" /f /t REG_EXPAND_SZ /d "%%PROGRAMFILES%%\Git\git-bash.exe"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "Git Bash"
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\" -p \"git bash\" -d \"%%V\""

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\03PowerShell
reg add "%ENTRY_KEY%" /v "Icon" /f /d "imageres.dll,-5372"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "PowerShell"
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\" -p \"PowerShell\" -d \"%%V\""

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\04WinPowerShell
reg add "%ENTRY_KEY%" /v "Icon" /f /d "imageres.dll,-5372"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "Windows PowerShell (Legacy)"
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\" -p \"Windows PowerShell\" -d \"%%V\""

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\05Ubuntu
reg add "%ENTRY_KEY%" /v "Icon" /f /d "wsl.exe,-1"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "Ubuntu"
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "\"%%LOCALAPPDATA%%\Microsoft\WindowsApps\wt.exe\" -p \"Ubuntu\" -d \"%%V\""

set ENTRY_KEY=%ROOT_MENU_KEY%\shell\runas
reg add "%ENTRY_KEY%" /v "CommandFlags" /f /t REG_DWORD /d 0x20
reg add "%ENTRY_KEY%" /v "HasLUAShield" /f
reg add "%ENTRY_KEY%" /v "Icon" /f /d "imageres.dll,-5323"
reg add "%ENTRY_KEY%" /v "MUIVerb" /f /d "Default Terminal (Elevated)"
rem Note: bouncing through cmd.exe as calling wt directly doesn't seem to work with elevation
reg add "%ENTRY_KEY%\command" /ve /t REG_EXPAND_SZ /f /d "cmd.exe /s /c pushd \"%%V\" & start wt -d ."

rem Add above menu to various places in the Explorer tree

rem Add to folder in the file pane of explorer
set MENU_KEY=HKCU\Software\Classes\Directory\shell\WindowsTerminalHereMenu
reg add "%MENU_KEY%" /v "MUIVerb" /f /d "Windows Terminal Here"
reg add "%MENU_KEY%" /v "Icon" /f /t REG_EXPAND_SZ /d "imageres.dll,-5323"
reg add "%MENU_KEY%" /v "ExtendedSubCommandsKey" /f /d "Directory\ContextMenus\WindowsTerminalHereMenu"

rem Add to the background in the file pane of explorer
set MENU_KEY=HKCU\Software\Classes\Directory\Background\shell\WindowsTerminalHereMenu
reg add "%MENU_KEY%" /v "MUIVerb" /f /d "Windows Terminal Here"
reg add "%MENU_KEY%" /v "Icon" /f /t REG_EXPAND_SZ /d "imageres.dll,-5323"
reg add "%MENU_KEY%" /v "ExtendedSubCommandsKey" /f /d "Directory\ContextMenus\WindowsTerminalHereMenu"

rem TODO: work with the following locations?
rem   HKCR\Drive\shell\WindowsTerminalHereMenu
rem   HKCR\Directory\LibraryFolder\shell\WindowsTerminalHereMenu
rem   HKCR\LibraryFolder\Background\shell\WindowsTerminalHereMenu

rem ################################################################################################
rem This doc page and surrounding pages have general info on creating submenus:
rem
rem   https://docs.microsoft.com/en-us/windows/win32/shell/how-to-create-cascading-menus-with-the-extendedsubcommandskey-registry-entry
rem
rem However, that specific page contains straight-up wrong information.  Other pages are more useful:
rem 
rem   http://io-repo.blogspot.com/2011/05/cascading-context-menus-via-static.html
rem   https://docs.microsoft.com/en-us/archive/blogs/andrew_richards/enhancing-the-open-command-prompt-here-shift-right-click-context-menu-experience
rem   https://littlemissgoth.livejournal.com/108477.html
rem   https://littlemissgoth.livejournal.com/107835.html
rem   https://littlemissgoth.livejournal.com/107277.html
rem   https://github.com/KUTlime/PowerShell-Open-Here-Module
rem
rem That all said, all of this was read in attempting to get a single submenu that contained one
rem entry per shell, all of which launched elevated.  As it turns out, elevation is triggered via
rem a "runas" verb, and there can only be one of those per menu.  So.... punt.  You get one
rem elevation menu entry.
rem ################################################################################################

endlocal
