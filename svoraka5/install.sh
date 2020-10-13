#!/bin/sh

#Install super best svorak A5
echo "To install svorak we need sudo..."
sudo cp se /usr/share/X11/xkb/symbols/se
sudo cp evdev.xml /usr/share/X11/xkb/rules/evdev.xml
echo "You can now use 'setxkbmap se -variant svorak' or pick the flavor in the menu in order to use awesome svorak."
