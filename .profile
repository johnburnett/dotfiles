# ~/.profile
# Personal environment variables and startup programs
# Personal aliases and functions should go in ~/.bashrc.

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

start_ssh_agent
