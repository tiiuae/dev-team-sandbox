#! /usr/bin/env bash
# shellcheck shell=bash
# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

# Notes:
#   Thi script can be used enroll finger print

set +xo pipefail

mainmenu () {
echo "Please choose which finger you want to enroll"
echo "1.  Right Thumb"
echo "2.  Right Index Finger"
echo "3.  Right Middle Finger"
echo "4.  Right Ring Finger"
echo "5.  Right Little Finger"
echo "6.  Left Thumb"
echo "7.  Left Index Finger"
echo "8.  Left Middle Finger"
echo "9.  Left Ring Finger"
echo "10. Left Little Finger"
}

while true; do
mainmenu
read  -r -n 2 -p "Input Selection:" mainmenuinput
echo ""
  if [ "$mainmenuinput" = "1" ]; then
            fprintd-enroll -f right-thumb
        elif [ "$mainmenuinput" = "2" ]; then
            fprintd-enroll -f right-index-finger
        elif [ "$mainmenuinput" = "3" ]; then
            fprintd-enroll -f right-middle-finger
        elif [ "$mainmenuinput" = "4" ]; then
            fprintd-enroll -f right-ring-finger
        elif [ "$mainmenuinput" = "5" ]; then
            fprintd-enroll -f right-little-finger
        elif [ "$mainmenuinput" = "6" ];then
            fprintd-enroll -f left-thumb
        elif [ "$mainmenuinput" = "7" ];then
            fprintd-enroll -f left-index-finger
        elif [ "$mainmenuinput" = "8" ];then
            fprintd-enroll -f left-middle-finger
        elif [ "$mainmenuinput" = "9" ];then
            fprintd-enroll -f left-ring-finger
        else
        fprintd-enroll -f left-little-finger
    fi
    echo ""
    exit 0
done