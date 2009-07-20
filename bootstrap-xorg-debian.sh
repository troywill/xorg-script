#!/bin/bash
# July 2009 TDW
# This are some Debian packages required the build X
aptitude install bzip2 sudo rsync openssh-server git-core pkg-config build-essential autoconf libtool python mlocate xsltproc libexpat1-dev libfreetype6-dev
# xsltproc is required by XCB
# July 2009: libexpat1-dev: during building libGL => Expat required for DRI
# libfreetype6-dev => required by libXfont
