#!/bin/bash
# July 2009 TDW
# This are some Debian packages required the build X
aptitude install build-essential emacs22-nox git-core autoconf libtool bzip2 sudo rsync openssh-server pkg-config python mlocate xsltproc libexpat1-dev libfreetype6-dev libssl-dev gettext bison flex intltool libglib2.0-dev
# xsltproc is required by XCB
# July 2009: libexpat1-dev: during building libGL => Expat required for DRI
# libfreetype6-dev => required by libXfont
# gettext => msgfmt ( jhbuild )
# bison, flex => needed by twm
# intltoolize => needed by xkeyboard-config
# xkeyboard-config => AM_GLIB_GNU_GETTEXT: command not found => libglib2.0-dev

