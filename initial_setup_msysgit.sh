#!/bin/bash

lndir() {
    existing_target=$1
    link_name=$2
    linkcmd="mklink /d \"$link_name\" \"$existing_target\""
    if [[ ! -d $link_name ]]; then
        if [[ -e $link_name ]]; then
            echo "$link_name already exists but is not not a directory, skipping link to $existing_target."
        else
            cmd <<< $linkcmd
        fi
    fi
}

echo Linking .ssh dir
lndir "G:\My Drive\.ssh" "$USERPROFILE\.ssh"
