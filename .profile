# ~/.profile
# Personal environment variables and startup programs
# Personal aliases and functions should go in ~/.bashrc.

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)                export LINUX_FLAVOR=darwin;;
    Linux*)                 export LINUX_FLAVOR=linux;;
    CYGWIN*|MINGW*|MSYS*)   export LINUX_FLAVOR=msys;;
esac
if [[ -n ${WSL_DISTRO_NAME} ]]; then
    export LINUX_FLAVOR=wsl
fi
if [[ -z "$LINUX_FLAVOR" ]]; then
    read -p "Unsupported distro"
    exit 1
fi

# Source personal aliases and functions
FILE=~/.bashrc && test -f $FILE && . $FILE

# I'm not putting personal environment variables in here because
# this doesn't get re-eval'd until a logout/login takes place.

start_ssh_agent() {
    env=~/.ssh/agent.env

    agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

    agent_start () {
        (umask 077; ssh-agent >| "$env")
        . "$env" >| /dev/null ; }

    agent_load_env

    # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
    agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

    if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
        agent_start
        ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
        ssh-add
    fi

    unset env
}

if [[ $LINUX_FLAVOR != wsl ]]; then
    # don't care enough to make this work in wsl just yet
    start_ssh_agent
fi
