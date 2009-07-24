#!/bin/bash
# July 2009 TDW
# This are some Debian packages required the build X
aptitude install build-essential emacs22-nox git-core autoconf libtool bzip2 sudo rsync openssh-server pkg-config python mlocate xsltproc libexpat1-dev libfreetype6-dev libssl-dev gettext flex
# xsltproc is required by XCB
# July 2009: libexpat1-dev: during building libGL => Expat required for DRI
# libfreetype6-dev => required by libXfont
# gettext => msgfmt ( jhbuild )
# flex => needed by twm

