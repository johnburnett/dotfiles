#!/bin/bash
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
###############################################################################
# Create a bunch of files that show off LS_COLORS
###############################################################################
mkdir LS_COLORS_TEST
cd LS_COLORS_TEST
touch 02_fi_file
mkdir 04_di_non-sticky-dir
ln -s 04_di_non-sticky-dir 05_ln_symlink
touch 06_mh_multi-hardlink-a
#ln -P 06_mh_multi-hardlink-a 06_mh_multi-hardlink-b
mkfifo 07_pi_fifo-pipe
#ln -P /tmp/.X11-unix/X0 08_so_socket
ln -s missing 12_or_orphaned-symlink
touch 13_su_setuid-file
chmod u+s 13_su_setuid-file
touch 14_sg_setgid-file
chmod g+s 14_sg_setgid-file
mkdir 16_tw_sticky-other-writable
chmod +t,o+w 16_tw_sticky-other-writable
mkdir 17_ow_non-sticky-other-writable
chmod o+w 17_ow_non-sticky-other-writable
mkdir 18_st_sticky-dir
chmod +t 18_st_sticky-dir
touch 19_ex_executable
chmod +x 19_ex_executable
touch windows.exe
\ls -AlF --color=auto --group-directories-first
cd ..
rm -rf LS_COLORS_TEST
