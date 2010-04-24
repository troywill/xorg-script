#!/bin/sh
PREFIX="/usr/local"
DESTDIR="/stow/xorg.2009-07-18"
PKG_CONFIG_PATH="/usr/lib/pkgconfig"

# Attempt to detect proper concurrency level
CPU_CORES=`cat /proc/cpuinfo | grep -m1 "cpu cores" | sed s/".*: "//`
CONCURRENCY_LEVEL=$(( $CPU_CORES + 1 ))

MAKE="make"
INSTALL="sudo make DESTDIR=${DESTDIR} install"
STOW="sudo stow --verbose xorg.2009-07-18"

REPOSITORIES="\
git://git.freedesktop.org/git/xorg/util/macros \
git://git.freedesktop.org/git/xorg/proto/x11proto \
git://git.freedesktop.org/git/xorg/proto/damageproto \
git://git.freedesktop.org/git/xorg/proto/xextproto \
git://git.freedesktop.org/git/xorg/proto/fontsproto \
git://git.freedesktop.org/git/xorg/proto/videoproto \
git://git.freedesktop.org/git/xorg/proto/renderproto \
git://git.freedesktop.org/git/xorg/proto/inputproto \
git://git.freedesktop.org/git/xorg/proto/xf86vidmodeproto \
git://git.freedesktop.org/git/xorg/proto/xf86dgaproto \
git://git.freedesktop.org/git/xorg/proto/xf86driproto \
git://git.freedesktop.org/git/xorg/proto/xcmiscproto \
git://git.freedesktop.org/git/xorg/proto/scrnsaverproto \
git://git.freedesktop.org/git/xorg/proto/bigreqsproto \
git://git.freedesktop.org/git/xorg/proto/resourceproto \
git://git.freedesktop.org/git/xorg/proto/compositeproto \
git://git.freedesktop.org/git/xorg/proto/fixesproto \
git://git.freedesktop.org/git/xorg/proto/evieproto \
git://git.freedesktop.org/git/xorg/proto/kbproto \
git://git.freedesktop.org/git/xorg/lib/libxtrans \
git://git.freedesktop.org/git/xorg/lib/libX11 \
git://git.freedesktop.org/git/xorg/lib/libXext \
git://git.freedesktop.org/git/xorg/lib/libxkbfile \
git://git.freedesktop.org/git/xorg/lib/libfontenc \
git://git.freedesktop.org/git/xorg/lib/libXfont \
git://git.freedesktop.org/git/xorg/lib/libXfixes \
git://git.freedesktop.org/git/xorg/lib/libXdamage \
git://git.freedesktop.org/git/xorg/lib/libXv \
git://git.freedesktop.org/git/xorg/lib/libXvMC \
git://git.freedesktop.org/git/xorg/lib/libXxf86vm \
git://git.freedesktop.org/git/xorg/lib/libXinerama \
git://git.freedesktop.org/git/xorg/proto/dri2proto \
git://git.freedesktop.org/git/xorg/proto/glproto \
git://git.freedesktop.org/git/xorg/lib/libpciaccess \
git://git.freedesktop.org/git/pixman \
git://git.freedesktop.org/git/xcb/proto \
git://git.freedesktop.org/git/xcb/pthread-stubs \
git://git.freedesktop.org/git/xcb/libxcb \
git://git.freedesktop.org/git/xorg/proto/randrproto \
git://git.freedesktop.org/git/mesa/drm \
git://git.freedesktop.org/git/mesa/mesa \
git://git.freedesktop.org/git/xorg/xserver \
git://git.freedesktop.org/git/xorg/driver/xf86-input-mouse \
git://git.freedesktop.org/git/xorg/driver/xf86-input-keyboard \
git://git.freedesktop.org/git/xorg/driver/xf86-video-intel"

modules="\
fontsproto \
x11proto \
xextproto \
videoproto \
renderproto \
inputproto \
damageproto \
xf86vidmodeproto \
xf86dgaproto \
xf86driproto \
xcmiscproto \
scrnsaverproto \
bigreqsproto \
resourceproto \
compositeproto \
resourceproto \
evieproto \
kbproto \
fixesproto \
libxtrans \
proto \
pthread-stubs \
libxcb \
libX11 \
libXext \
libxkbfile \
libfontenc \
libXfont \
libXv \
libXvMC \
libXxf86vm \
libXinerama \
libXfixes \
libXdamage \
dri2proto \
glproto \
libpciaccess \
pixman \
randrproto"

initialize()
{
#     for repo in $REPOSITORIES; do
#         echo "Cloning $repo"
#         git clone $repo
#     done
    cd macros
    echo "Building macros"
    ./autogen.sh --prefix="$PREFIX"
    ${MAKE}
    ${INSTALL}
    ${STOW}
    cd ..
}

build ()
{
    export ACLOCAL="aclocal -I $PREFIX/share/aclocal"
    export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
    for i in $modules; do
        cd $i
        ./autogen.sh --prefix="$PREFIX"
        if [ $? -ne 0 ]; then
            echo "Failed to configure $i."
            exit
        fi
        ($MAKE)
	${INSTALL}
	${STOW}
	sleep 10
        cd ..
    done
}


case "$1" in
    initialize)
        initialize
        ;;
    build)
        build
        ;;
    update)
        update_modules
        ;;
    *)
        echo "Usage: $0 initialize | build | update"
        exit 3
esac
