#!/bin/sh
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
git://git.freedesktop.org/git/xorg/lib/libXau \
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

clone()
{
    for repo in $REPOSITORIES; do
        echo "Cloning $repo"
        git clone $repo
    done
    cd macros
}

case "$1" in
    clone)
        clone
        ;;
    update)
        update_modules
        ;;
    *)
        echo "Usage: $0 clone | update"
        exit 3
esac
