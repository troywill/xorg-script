PREFIX="/opt/gfx-test"
PKG_CONFIG_PATH=/opt/gfx-test/lib/pkgconfig
LOG_FILE="${HOME}/xorg.log"
echo $LOG_FILE

make_install_prompt ()
{
    echo -n "Press Enter to install $1 ..."
    read -e COLOR
}

# Attempt to detect proper concurrency level
CPU_CORES=`cat /proc/cpuinfo | grep -m1 "cpu cores" | sed s/".*: "//`
CONCURRENCY_LEVEL=$(( $CPU_CORES + 1 ))

MAKE="make"

REPOS="\
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
git://git.freedesktop.org/git/xorg/lib/libXau \
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
libXau \
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

init()
{
        for repo in $REPOS; do
                echo "Cloning $repo"
                git clone $repo
        done
        cd macros
        echo "Building macros"
        ./autogen.sh --prefix="$PREFIX"
        ($MAKE)
        make install
        cd ..
}

update_modules()
{
        for module in $modules; do
                echo "Updating $module"
                cd $module
                git pull
                cd ..
        done
}

build ()
{
        export ACLOCAL="aclocal -I $PREFIX/share/aclocal"
        export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
        for i in $modules; do
                cd $i
                echo ======================
                echo configuring $i
		echo "configuring $i" `date` >> $LOG_FILE
                echo ======================
                ./autogen.sh --prefix="$PREFIX"
                echo ======================
                echo building $i
                echo ======================
                if [ $? -ne 0 ]; then
                        echo "Failed to configure $i."
                        exit
                fi
                ($MAKE)
		make_install_prompt $i
                make install
                cd ..
        done
        # build drm
        cd drm
        ./autogen.sh --prefix="$PREFIX"
        ($MAKE)
        make -C linux-core
        # assuming you're on Linux, otherwise use bsd-core
        make install
        cd ..
#build mesa
        cd mesa
        ./autogen.sh --prefix=$PREFIX --with-driver=dri --disable-glut --with-state-trackers="egl dri2"
        if [ $? -ne 0 ]; then
                echo "Failed to configure Mesa."
                exit
        fi
        ($MAKE)
        make install
        mkdir -p $PREFIX/bin
        install -m755 progs/xdemos/{glxinfo,glxgears} $PREFIX/bin/
        cd ..
#buildxserver
        cd xserver
        ./autogen.sh --prefix=$PREFIX --enable-builtin-fonts
        if [ $? -ne 0 ]; then
                echo "Failed to configure X server."
                exit
        fi
        ($MAKE)
        make install
        chown root $PREFIX/bin/Xorg
        chmod +s $PREFIX/bin/Xorg
        cd ..
#mouse
        cd xf86-input-mouse
        ./autogen.sh --prefix=$PREFIX
        ($MAKE)
        make install
        cd ..
#keyboard

        cd xf86-input-keyboard
        ./autogen.sh --prefix=$PREFIX
        ($MAKE)
        make install
        cd ..
#intel
        cd xf86-video-intel
        ./autogen.sh --prefix=$PREFIX
        ($MAKE)
        make install
        cd ..
}

case "$1" in
        init)
                init
                ;;
        build)
                build
                ;;
        update)
                update_modules
                ;;
        *)
                echo "Usage: $0 init | build | update"
                exit 3
esac
