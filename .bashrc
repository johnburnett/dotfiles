# ~/.bashrc
# Personal aliases and functions

FILE=/etc/bashrc && test -f $FILE && . $FILE
FILE=~/.alias && test -f $FILE && . $FILE

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
THIS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

###############################################################################
# Functions

# Functions to help manage paths
# usage: PATH [VAR] [after]
#   PATH: path to work with
#   VAR: variable to be modified (default: PATH)
#   after: append (default: prepend)
# examples:
#   pathmod $HOME/bin after
#   pathmod ~/python/lib PYTHONPATH
pathremove () {
    local PVAR=${2:-PATH}
    local P=(${!PVAR//:/ })
    P=(${P[@]%%$1})
    local IFS=:
    export ${2:-PATH}="${P[*]}"
}
pathmod () {
    local PVAR=${2:-PATH}
    [ "$3" = "after" ] && PVAR=$2
    pathremove $1 $PVAR
    if [ "$2" = 'after' -o "$3" = 'after' ]; then
        export $PVAR="${!PVAR:+${!PVAR}:}$1"
    else
        export $PVAR="$1${!PVAR:+:${!PVAR}}"
    fi
}

function ff() { find . -type f -iname '*'$*'*' ; }
function toLower() { echo $1 | tr "[:upper:]" "[:lower:]"; }
function toUpper() { echo $1 | tr "[:lower:]" "[:upper:]"; }
function forwardSlash() { echo $1 | tr '\\' "/"; }
function backSlash() { echo $1 | tr "/" '\\'; }

###############################################################################
# Environment exports

export PYTHONSTARTUP=$THIS_DIR/pythonrc.py
export PYTHONDONTWRITEBYTECODE=1

export GREP_COLOR='1;32'

export EDITOR=nano
export SVN_EDITOR=nano

###############################################################################
# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
#
# Text color codes:
# 30  = light green
# 31  = red
# 32  = green
# 33  = orange
# 34  = blue
# 35  = purple
# 36  = cyan
# 37  = grey
# 90  = dark grey
# 91  = light red
# 92  = light green
# 93  = yellow
# 94  = light blue
# 95  = light purple
# 96  = turquoise
#
# Background color codes:
# 40  = black background
# 41  = red background
# 42  = green background
# 43  = orange background
# 44  = blue background
# 45  = purple background
# 46  = cyan background
# 47  = grey background
# 100 = dark grey background
# 101 = light red background
# 102 = light green background
# 103 = yellow background
# 104 = light blue background
# 105 = light purple background
# 106 = turquoise background
#
# File attribute types
# 01 no: NORMAL - no color code at all
# 02 fi: FILE - regular file: use no color at all
# 03 rs: RESET - reset to "normal" color
# 04 di: DIR - directory
# 05 ln: LINK - symbolic link. (If you set this to 'target' instead of a
#               numerical value, the color is as for the file pointed to.)
# 06 mh: MULTIHARDLINK - regular file with more than one link
# 07 pi: FIFO - pipe
# 08 so: SOCK - socket
# 09 do: DOOR - door
# 10 bd: BLK - block device driver
# 11 cd: CHR - character device driver
# 12 or: ORPHAN - symlink to nonexistent file, or non-stat'able file
# 13 su: SETUID - file that is setuid (u+s)
# 14 sg: SETGID - file that is setgid (g+s)
# 15 ca: CAPABILITY - file with capability
# 16 tw: STICKY_OTHER_WRITABLE - dir that is sticky and other-writable (+t,o+w)
# 17 ow: OTHER_WRITABLE - dir that is other-writable (o+w) and not sticky
# 18 st: STICKY - dir with the sticky bit set (+t) and not other-writable
# 19 ex: EXEC - This is for files with execute permission:
#
###############################################################################
# Create a bunch of files that show off LS_COLORS
###############################################################################
# mkdir LS_COLORS_TEST
# cd LS_COLORS_TEST
# touch 02_fi_file
# mkdir 04_di_non-sticky-dir
# ln -s 04_di_non-sticky-dir 05_ln_symlink
# touch 06_mh_multi-hardlink-a
# ln -P 06_mh_multi-hardlink-a 06_mh_multi-hardlink-b
# mkfifo 07_pi_fifo-pipe
# ln -P /tmp/.X11-unix/X0 08_so_socket
# ln -s missing 12_or_orphaned-symlink
# touch 13_su_setuid-file
# chmod u+s 13_su_setuid-file
# touch 14_sg_setgid-file
# chmod g+s 14_sg_setgid-file
# mkdir 16_tw_sticky-other-writable
# chmod +t,o+w 16_tw_sticky-other-writable
# mkdir 17_ow_non-sticky-other-writable
# chmod o+w 17_ow_non-sticky-other-writable
# mkdir 18_st_sticky-dir
# chmod +t 18_st_sticky-dir
# touch 19_ex_executable
# chmod +x 19_ex_executable
# touch windows.exe
# \ls -AlF --color=auto
# cd ..
# rm -rf LS_COLORS_TEST
###############################################################################
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;92:ln=00;94:mh=04:pi=00;33:so=00;33:bd=00;33:cd=00;33:or=01;94:su=01;31:sg=01;31:tw=01;92:ow=01;92:st=01;92:ex=00;31';
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi

#export HISTSIZE=10000
# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
#HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="&:ls:la:sls:[bf]g:exit:set:e:alias:pipe:f"
#export HISTFILE="${HOME}/.history/$(date -u +%Y%m%d.%H%M%S)_${HOSTNAME}_$$"
#histgrep () {
#    grep -r "$@" ~/.history
#    history | grep "$@"
#}

###############################################################################
# Any other aliases and functions should go below this line
###############################################################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

###############################################################################
# Set things inside of functions to avoid polluting outside environment

setPrompt() {
	# Prompt colors codes
	local noColor='\e[0m'
	local resetColor='\e[40m'

	local dimBlack='\e[0;30m'
	local dimRed='\e[0;31m'
	local dimGreen='\e[0;32m'
	local dimYellow='\e[0;33m'
	local dimBlue='\e[0;34m'
	local dimPurple='\e[0;35m'
	local dimCyan='\e[0;36m'
	local dimWhite='\e[0;37m'

	local black='\e[1;30m'
	local red='\e[1;31m'
	local green='\e[1;32m'
	local yellow='\e[1;33m'
	local blue='\e[1;34m'
	local purple='\e[1;35m'
	local cyan='\e[1;36m'
	local white='\e[1;37m'

	local backBlack='\e[40m'
	local backRed='\e[41m'
	local backGreen='\e[42m'
	local backYellow='\e[43m'
	local backBlue='\e[44m'
	local backPurple='\e[45m'
	local backCyan='\e[46m'
	local backWhite='\e[47m'

	export PROMPT_COMMAND='RET_VALUE=$?; history -a'
	export PS1="\[$green\]\$PWD\n\[$yellow\]\$RET_VALUE \[$purple\]\u@\h\$\[$noColor\] "
}
setPrompt
unset setPrompt

shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s extglob
shopt -s nocaseglob

# enable bash completion in interactive shells
FILE=/etc/bash_completion && test -f $FILE && . $FILE

###############################################################################
# Key bindings

# tab/shift-tab to complete next/prev
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'
# ctrl-right/left for next/prev word
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'
# up/down to search history using current input
bind '"\e[B": history-search-forward'
bind '"\e[A": history-search-backward'

setAlias() {
	# Create N "...." style aliases
	local upAlias=".."
	local upCmd="cd .."
	for ii in {1..9}; do
		alias $upAlias="$upCmd"
		HISTIGNORE=$HISTIGNORE":"$upAlias
		upAlias=$upAlias"."
		upCmd=$upCmd"/.."
	done
}
setAlias
unset setAlias

# source $THIS_DIR/../internal/.bashrc
