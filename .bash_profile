# ~/.bash_profile
# Personal environment variables and startup programs

# Personal aliases and functions should go in ~/.bashrc.
# System wide aliases and functions are in /etc/bashrc.
# System wide environment variables and startup programs are in /etc/profile.

# Source personal aliases and functions
FILE=~/.bashrc && test -f $FILE && . $FILE

# I'm not putting personal environment variables in here because
# this doesn't get re-eval'd until a logout/login takes place.
