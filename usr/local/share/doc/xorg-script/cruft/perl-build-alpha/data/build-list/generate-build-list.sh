#!/bin/bash
jhbuild list xserver xf86-video-intel xf86-input-keyboard xkeyboard-config xf86-input-mouse xorg-apps > temp1
jhbuild list xserver xf86-video-intel xf86-input-keyboard xkeyboard-config xf86-input-mouse xorg-apps xorg-fonts > temp2
# manually remove meta modules xorg-protos and xorg-apps
