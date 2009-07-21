use warnings;
use strict;

my $GIT_BASE = 'git://git.freedesktop.org/git/';
my $LOG_FILE = 'repository-validity.log';
my @protoArray = &build_protoArray();
my @AoA = &build_protoArray();

sub build_protoArray {
    
    my @ProtoArray = (
	[ 'macros', 'xorg/util/macros'],
	[ 'bigreqsproto', 'xorg/proto/bigreqsproto' ],
	[ 'compositeproto', 'xorg/proto/compositeproto' ],
	[ 'damageproto', 'xorg/proto/damageproto' ],
	[ 'dmxproto', 'xorg/proto/dmxproto' ],
	[ 'fixesproto', 'xorg/proto/fixesproto' ],
	[ 'fontsproto', 'xorg/proto/fontsproto' ],
	[ 'glproto', 'xorg/proto/glproto' ],
	[ 'inputproto', 'xorg/proto/inputproto' ],
	[ 'kbproto', 'xorg/proto/kbproto' ],
	[ 'xineramaproto', 'xorg/proto/xineramaproto' ],
	[ 'randrproto', 'xorg/proto/randrproto' ],
	[ 'recordproto', 'xorg/proto/recordproto' ],
	[ 'renderproto', 'xorg/proto/renderproto' ],
	[ 'resourceproto', 'xorg/proto/resourceproto' ],
	[ 'scrnsaverproto', 'xorg/proto/scrnsaverproto' ],
	[ 'videoproto', 'xorg/proto/videoproto' ],
	[ 'xcmiscproto', 'xorg/proto/xcmiscproto' ],
	[ 'xextproto', 'xorg/proto/xextproto' ],
	[ 'xf86bigfontproto', 'xorg/proto/xf86bigfontproto' ],
	[ 'xf86dgaproto', 'xorg/proto/xf86dgaproto' ],
	[ 'xf86driproto', 'xorg/proto/xf86driproto' ],
	[ 'xf86vidmodeproto', 'xorg/proto/xf86vidmodeproto' ],
	[ 'x11proto', 'xorg/proto/x11proto' ],
	[ 'dri2proto', 'xorg/proto/dri2proto' ],
	[ 'xorg-protos', 'xorg/proto/xorg-protos' ],
	[ 'xcb-proto', 'xorg/xcb/xcb-proto' ],
	);

    return @ProtoArray;
}

__END__
