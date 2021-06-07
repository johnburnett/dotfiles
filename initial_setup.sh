#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
THIS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
pushd $THIS_DIR &> /dev/null

if [[ -n ${WSL_DISTRO_NAME} ]]; then
    LINUX_FLAVOR=wsl
elif [[ -n ${XDG_DATA_DIRS+x} ]]; then
    LINUX_FLAVOR=linux
elif [[ -n ${WINDIR} ]]; then
    LINUX_FLAVOR=msysgit
else
    echo "Unsupported distro"
    exit 1
fi

# Setup shims
case $LINUX_FLAVOR in
    wsl)
        lndotfiles() {
            # target should be an absolute path, as we don't have dotfiles dir
            # checked out into wsl home dir
            linktarget=`readlink -f $1`
            linkname=~/$1
            ln -sfT $linktarget $linkname
        }
        ;;

    linux)
        lndotfiles() {
            linktarget=dotfiles/$1
            linkname=../$1
            ln -sfT $linktarget $linkname
        }
        ;;

    msysgit)
        lndotfiles() {
            linktarget=dotfiles\\$1
            linkname=..\\$1
            linkcmd="mklink \"$linkname\" \"$linktarget\""
            if [[ ! -f $linktarget ]]; then {
                cmd <<< $linkcmd
            }
            fi
        }
        ;;
esac

echo Linking dot files
lndotfiles .alias
lndotfiles .profile
lndotfiles .bashrc
lndotfiles .inputrc
lndotfiles .nanorc
lndotfiles .gitconfig

flavor_initial_setup=initial_setup_$LINUX_FLAVOR.sh
if [[ -f $flavor_initial_setup ]]; then
    echo Running $flavor_initial_setup
    source $flavor_initial_setup
fi

# source $THIS_DIR/../internal/.bashrc

popd &> /dev/null
