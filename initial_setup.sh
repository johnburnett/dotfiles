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
    dist=wsl
elif [[ -n ${XDG_DATA_DIRS+x} ]]; then
    dist=linux
elif [[ -n ${WINDIR} ]]; then
    dist=msysgit
else
    echo "Unsupported distro"
    exit 1
fi

# Setup shims
case $dist in
    wsl)
        lnconfig() {
            # target should be an absolute path, as we don't have config dir
            # checked out into wsl home dir
            linktarget=`readlink -f $1`
            linkname=~/$1
            ln -sfT $linktarget $linkname
        }
        ;;

    linux)
        lnconfig() {
            linktarget=config/$1
            linkname=../$1
            ln -sfT $linktarget $linkname
        }
        ;;

    msysgit)
        lnconfig() {
            linktarget=config\\$1
            linkname=..\\$1
            linkcmd="mklink \"$linkname\" \"$linktarget\""
            if [[ ! -f $linktarget ]]; then {
                cmd <<< $linkcmd &> /dev/null
            }
            fi
        }
        ;;
esac

echo Linking dot files
lnconfig .alias
lnconfig .profile
lnconfig .bashrc
lnconfig .inputrc
lnconfig .nanorc
lnconfig .gitconfig

platform_initial_setup=initial_setup_$dist.sh
if [[ -f $platform_initial_setup ]]; then
    echo Running $platform_initial_setup
    source $platform_initial_setup
fi

# source $THIS_DIR/../internal/.bashrc

popd &> /dev/null
