#!/bin/bash

# Setup initial config on fresh profile
# gsettings     # gnome config command line editor
# gsettings list-recursively | grep -i "thing"
# dconf-editor  # gnome config gui editor
# dconf watch / # watch changes as they're edited
# https://developer.gnome.org/integration-guide/stable/desktop-files.html.en

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
THIS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

dconf write /org/cinnamon/settings-daemon/peripherals/keyboard/delay "uint32 230"
dconf write /org/cinnamon/settings-daemon/peripherals/keyboard/repeat-interval "uint32 17"
dconf write /org/cinnamon/settings-daemon/peripherals/keyboard/numlock-state "'on'"

dconf write /org/gnome/calculator/show-thousands true
dconf write /org/gnome/calculator/button-mode '"programming"'

profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1} # remove leading and trailing single quotes
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/audible-bell true
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/background-color '"rgb(0,0,0)"'
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/bold-color-same-as-fg true
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/default-size-columns 160
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/default-size-rows 40
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/foreground-color '"rgb(255,255,255)"'
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/scrollback-unlimited false
dconf write /org/gnome/terminal/legacy/profiles:/:$profile/use-theme-colors false

dconf write /com/gexperts/Tilix/new-window-inherit-state true
dconf write /com/gexperts/Tilix/prompt-on-close true
dconf write /com/gexperts/Tilix/terminal-title-style '"small"'
dconf write /com/gexperts/Tilix/theme-variant '"dark"'
profile=$(gsettings get com.gexperts.Tilix.ProfilesList default)
profile=${profile:1:-1} # remove leading and trailing single quotes
dconf write /com/gexperts/Tilix/profiles/$profile/background-color '"#272822"'
dconf write /com/gexperts/Tilix/profiles/$profile/badge-color-set false
dconf write /com/gexperts/Tilix/profiles/$profile/bold-color-set false
dconf write /com/gexperts/Tilix/profiles/$profile/cursor-colors-set false
dconf write /com/gexperts/Tilix/profiles/$profile/default-size-columns 160
dconf write /com/gexperts/Tilix/profiles/$profile/default-size-rows 40
dconf write /com/gexperts/Tilix/profiles/$profile/foreground-color '"#F8F8F2"'
dconf write /com/gexperts/Tilix/profiles/$profile/highlight-colors-set false
dconf write /com/gexperts/Tilix/profiles/$profile/palette '["#272822", "#F92672", "#A6E22E", "#F4BF75", "#66D9EF", "#AE81FF", "#A1EFE4", "#F8F8F2", "#75715E", "#F92672", "#A6E22E", "#F4BF75", "#66D9EF", "#AE81FF", "#A1EFE4", "#F9F8F5"]'
dconf write /com/gexperts/Tilix/profiles/$profile/scrollback-unlimited true
dconf write /com/gexperts/Tilix/profiles/$profile/terminal-bell '"none"'
dconf write /com/gexperts/Tilix/profiles/$profile/use-theme-colors false

dconf write /org/cinnamon/desktop/wm/preferences/theme '"Mint-Y"'
dconf write /org/cinnamon/desktop/interface/gtk-theme '"Mint-Y"'
dconf write /org/cinnamon/theme/name '"Mint-Y"'

dconf write /org/cinnamon/desktop-effects false
dconf write /org/cinnamon/desktop-effects-close-effect '"traditional"'
dconf write /org/cinnamon/desktop-effects-close-time 175
dconf write /org/cinnamon/desktop-effects-close-transition '"easeOutQuad"'
dconf write /org/cinnamon/desktop-effects-map-effect '"traditional"'
dconf write /org/cinnamon/desktop-effects-map-time 175
dconf write /org/cinnamon/desktop-effects-map-transition '"easeOutQuad"'
dconf write /org/cinnamon/desktop-effects-maximize-effect '"none"'
dconf write /org/cinnamon/desktop-effects-maximize-time 100
dconf write /org/cinnamon/desktop-effects-maximize-transition '"easeInExpo"'
dconf write /org/cinnamon/desktop-effects-minimize-effect '"traditional"'
dconf write /org/cinnamon/desktop-effects-minimize-time 200
dconf write /org/cinnamon/desktop-effects-minimize-transition '"easeInQuad"'
dconf write /org/cinnamon/desktop-effects-on-dialogs false
dconf write /org/cinnamon/desktop-effects-on-menus false
dconf write /org/cinnamon/desktop-effects-tile-effect '"none"'
dconf write /org/cinnamon/desktop-effects-tile-time 100
dconf write /org/cinnamon/desktop-effects-tile-transition '"easeInQuad"'
dconf write /org/cinnamon/desktop-effects-unmaximize-effect '"none"'
dconf write /org/cinnamon/desktop-effects-unmaximize-time 100
dconf write /org/cinnamon/desktop-effects-unmaximize-transition '"easeNone"'
dconf write /org/cinnamon/desktop/interface/gtk-overlay-scrollbars false
dconf write /org/cinnamon/enable-vfade false
dconf write /org/cinnamon/startup-animation false

dconf write /org/cinnamon/desktop/background/picture-options '"scaled"'
dconf write /org/cinnamon/desktop/background/primary-color '"#000000000000"'
dconf write /org/cinnamon/desktop/background/secondary-color '"#000000000000"'
dconf write /org/cinnamon/desktop/background/color-shading-type '"solid"'
dconf write /org/cinnamon/desktop/background/slideshow/delay 15
dconf write /org/cinnamon/desktop/background/slideshow/slideshow-enabled true
dconf write /org/cinnamon/desktop/background/slideshow/random-order true
dconf write /org/cinnamon/desktop/background/slideshow/image-source '"directory://$HOME/Dropbox/backgrounds"'

dconf write /org/cinnamon/desktop/interface/clock-use-24h false
dconf write /org/cinnamon/desktop/interface/clock-show-date true
dconf write /org/cinnamon/desktop/interface/clock-show-seconds false

dconf write /org/nemo/desktop/show-desktop-icons true
dconf write /org/nemo/list-view/default-column-order "['name', 'size', 'type', 'date_modified', 'date_accessed', 'detailed_type', 'group', 'where', 'mime_type', 'octal_permissions', 'owner', 'permissions', 'selinux_context']"
dconf write /org/nemo/list-view/default-visible-columns "['name', 'size', 'date_modified', 'group', 'octal_permissions', 'owner', 'permissions']"
dconf write /org/nemo/list-view/default-zoom-level '"smallest"'
dconf write /org/nemo/preferences/date-format '"iso"'
dconf write /org/nemo/preferences/default-folder-viewer '"list-view"'
dconf write /org/nemo/preferences/ignore-view-metadata true
dconf write /org/nemo/preferences/quick-renames-with-pause-in-between true
dconf write /org/nemo/preferences/show-advanced-permissions true
dconf write /org/nemo/preferences/show-compact-view-icon-toolbar false
dconf write /org/nemo/preferences/show-full-path-titles true
dconf write /org/nemo/preferences/show-hidden-files false
dconf write /org/nemo/preferences/show-icon-view-icon-toolbar false
dconf write /org/nemo/preferences/show-list-view-icon-toolbar false
dconf write /org/nemo/preferences/show-location-entry true
dconf write /org/nemo/preferences/show-new-folder-icon-toolbar true
dconf write /org/nemo/preferences/show-next-icon-toolbar true
dconf write /org/nemo/preferences/show-open-in-terminal-toolbar true
dconf write /org/nemo/preferences/show-previous-icon-toolbar true

dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'terminal'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'/usr/bin/tilix'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding '["<Super>t"]'
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/name "'nemo'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/command "'/usr/bin/nemo'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/binding '["<Super>f"]'
dconf write /org/cinnamon/desktop/keybindings/custom-list '["custom0", "custom1"]'
dconf write /org/cinnamon/desktop/keybindings/looking-glass-keybinding '@as []' # disable default <Super>l
dconf write /org/cinnamon/desktop/keybindings/media-keys/screensaver '["<Control><Alt>l", "XF86ScreenSaver", "<Super>l"]'

dconf write /org/cinnamon/desktop/wm/preferences/mouse-button-modifier '"<Super>"'
dconf write /org/cinnamon/desktop/wm/preferences/action-middle-click-titlebar '"none"'

dconf write /org/gnome/libgnomekbd/keyboard/options '["caps\tcaps:ctrl_modifier"]'
dconf write /org/gnome/desktop/input-sources/xkb-options '["caps:ctrl_modifier"]'
# setxkbmap was needed to make programs line rdesktop and wine respect the
# capslock>ctrl remapping.  This was the recommended way to have the command
# run at login time.
DESKTOP_FILE=$HOME/.config/autostart/remap-capslock.desktop
cat > "$DESKTOP_FILE" <<-EOL
	[Desktop Entry]
	Comment=remap capslock to control
	Exec=/bin/bash -c "sleep 5 && /usr/bin/setxkbmap -option ctrl:nocaps"
	Icon=gohome
	Name=remap capslock to control
	Terminal=false
	Type=Application
EOL
chmod a+x "$DESKTOP_FILE"

DESKTOP_FILE=$HOME/.local/share/applications/gitkraken.desktop
cat > "$DESKTOP_FILE" <<-EOL
	[Desktop Entry]
	Categories=Development;
	Exec=$HOME/bin/linux/gitkraken %F
	Name=GitKraken
	StartupNotify=true
	Terminal=false
	Type=Application
	Version=1.0
EOL
chmod a+x "$DESKTOP_FILE"

DESKTOP_FILE=$HOME/.local/share/applications/sublime_text.desktop
cat > "$DESKTOP_FILE" <<-EOL
	[Desktop Entry]
	Categories=TextEditor;Development;
	Exec=$HOME/bin/linux/sublime_text
	Icon=sublime-text
	Name=Sublime Text
	StartupNotify=true
	Terminal=false
	Type=Application
EOL
chmod a+x "$DESKTOP_FILE"

ln -sfT $THIS_DIR/.alias ~/.alias
ln -sfT $THIS_DIR/.bash_profile ~/.bash_profile
ln -sfT $THIS_DIR/.bashrc ~/.bashrc
ln -sfT $THIS_DIR/.inputrc ~/.inputrc
ln -sfT $THIS_DIR/.nanorc ~/.nanorc

source $THIS_DIR/../internal/.bashrc
