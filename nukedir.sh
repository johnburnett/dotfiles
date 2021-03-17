ORIGINAL_WIN_DIR_PATH=$1
ORIGINAL_POSIX_DIR_PATH=$(cygpath --unix --absolute "$ORIGINAL_WIN_DIR_PATH")
read -n 1 -r -p "Permanently delete \"$ORIGINAL_WIN_DIR_PATH\"? (hit Y to confirm)"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DRIVE_LETTER=$(echo "$ORIGINAL_POSIX_DIR_PATH" | cut -d "/" -f2)
    NUKE_DIR_NAME=$(date '+nukedir_%Y%m%d_%H%M%S_%N')
    NUKE_DIR_PATH=/$DRIVE_LETTER/$NUKE_DIR_NAME
    if [[ -e $NUKE_DIR_PATH ]]; then
        read -n 1 -r -p "ERROR: nukedir path already exists: \"$NUKE_DIR_PATH\""
        exit 1
    fi
    echo
    echo Nuking...
    mv "$ORIGINAL_POSIX_DIR_PATH" "$NUKE_DIR_PATH" || {
        echo "ERROR: could not move path: \"$ORIGINAL_POSIX_DIR_PATH\""
        echo "Searching for uses:"
        $USERPROFILE/Dropbox/bin/handle64.exe -nobanner "$ORIGINAL_WIN_DIR_PATH"
        read -n 1 -r -p "Press any key to exit"
        exit 1
    }
    rm -rf "$NUKE_DIR_PATH"
fi
