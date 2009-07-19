#!/usr/bin/env perl
use strict;
use warnings;

my $PREFIX="/opt";
my $ACLOCAL="aclocal -I $PREFIX/share/aclocal";
my $PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig";
my $DIR='xorg.2009-07-18';
my $DESTDIR="/stow/$DIR";
my $MAKE = "make";
my $INSTALL = "sudo make DESTDIR=$DESTDIR install";
my $STOW = "sudo stow --verbose $DIR";
my @MODULE_LIST = &return_module_list;

# &initialize;
# &build_module( 'x11proto');
# &build_module( 'proto' );
# build_module( 'libXau' );
&build_all_modules (@MODULE_LIST);

#&build_module( 'libxcb' );
####################### Subroutines only below this line #################################

sub initialize {
    my $script = <<"END";
#!/bin/bash
set -o verbose
export ACLOCAL="$ACLOCAL"
make clean
./autogen.sh --prefix="$PREFIX"
$MAKE
$INSTALL
$STOW
END
    chdir "macros";
    open (SCRIPT, ">stow.macros.sh");
    print SCRIPT $script;
    close SCRIPT;
    chmod 0755, $script;
    print "Initializing ...\n";
    system("sh ./stow.macros.sh");
    chdir '..';
}

sub build_module {
    my $module = shift;
    chdir $module;
    print "---------------------------------------------------\n";
    print "         Building module $module                   \n";
    print "---------------------------------------------------\n";
    my $script = <<"END";
#!/bin/bash
set -o verbose
make clean
export ACLOCAL="$ACLOCAL"
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH
./autogen.sh --prefix=$PREFIX
$MAKE
$INSTALL
$STOW
END
    open (SCRIPT, ">stow.$module.sh");
    print SCRIPT $script;
    close SCRIPT;
    system ( "sh ./stow.$module.sh");
    chdir "..";
}

sub build_all_modules {
    my @MODULES = @_;
    foreach my $module ( @MODULES ) {
	&build_module( $module );
	print "Proceed?: ";
	<STDIN>;
    }
}



sub return_module_list {
    my @module_list = qw (
fontsproto
x11proto
xextproto
videoproto
renderproto
inputproto
damageproto
xf86vidmodeproto
xf86dgaproto
xf86driproto
xcmiscproto
scrnsaverproto
bigreqsproto
resourceproto
compositeproto
resourceproto
evieproto
kbproto
fixesproto
libxtrans
proto
pthread-stubs
libXau
libxcb
libX11
libXext
libxkbfile
libfontenc
libXfont
libXv
libXvMC
libXxf86vm
libXinerama
libXfixes
libXdamage
dri2proto
glproto
libpciaccess
pixman
randrproto
);

    return @module_list;
    
}

exit;
__END__
# Attempt to detect proper concurrency level
CPU_CORES=`cat /proc/cpuinfo | grep -m1 "cpu cores" | sed s/".*: "//`
CONCURRENCY_LEVEL=$(( $CPU_CORES + 1 ))

MAKE="make"
INSTALL="sudo make DESTDIR=${DESTDIR} install"
STOW="sudo stow --verbose gfx-test"

REPOSITORIES="\
git://git.freedesktop.org/git/xorg/lib/libXau \
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
    for repo in $REPOSITORIES; do
        echo "Cloning $repo"
        git clone $repo
    done
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
