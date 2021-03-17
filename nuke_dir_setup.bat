@echo off
setlocal

rem Create shared menu that is referenced by keys below.  Menu has one menu entry per shell.
rem Each entry launches Windows Terminal via wt using the given named profile.  Expects you have
rem corresponding named entries in your profiles.json.

set ROOT_MENU_KEY=HKCU\Software\Classes\Directory\shell\NukeDir
reg delete "%ROOT_MENU_KEY%" /f
reg add "%ROOT_MENU_KEY%" /ve /d "Nuke Directory"
reg add "%ROOT_MENU_KEY%" /v "Icon" /f /d "shell32.dll,109"
reg add "%ROOT_MENU_KEY%\command" /ve /t REG_EXPAND_SZ /d "\"%%PROGRAMFILES%%\Git\bin\bash.exe\" \"%%USERPROFILE%%\config\nukedir.sh\" \"%%1\""

endlocal
