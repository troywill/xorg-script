use warnings;
use strict;

my $GIT_BASE = 'git://git.freedesktop.org/git/';
my $LOG_FILE = 'repository-validity.log';
my @AoA = (
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


for ( 0..26 ) {
  &test( $_ );
}

sub test {
  chdir 'Git';
  my $id = shift;
  my $module = $AoA[$id][0];
  my $repository = $GIT_BASE . $AoA[$id][1];
  print "$module => $repository\n";
  my $command = "git clone $repository";
  print "----------------------------------------------------------\n";
  print "                  $module => $repository                  \n";
  print "----------------------------------------------------------\n";
  system $command;
  print "Success? y/n:";
  my $success = <STDIN>;
  chomp $success;
  &log( $id, $success );
  chdir '..';
}

sub log {
  my ( $id, $success ) = @_;
  my $module = $AoA[$id][0];
  my $repository = $AoA[$id][1];
  open ( OUT, ">>$LOG_FILE");
  print OUT "[$success]|$id|$module|$repository\n";
  close OUT;
}



__END__

macros
bigreqsproto
compositeproto
damageproto
dmxproto
fixesproto
fontsproto
glproto
inputproto
kbproto
xineramaproto
randrproto
recordproto
renderproto
resourceproto
scrnsaverproto
videoproto
xcmiscproto
xextproto
xf86bigfontproto
xf86dgaproto
xf86driproto
xf86vidmodeproto
x11proto
dri2proto
xorg-protos
xcb-proto
pthread-stubs
libXau
libxcb
libxtrans
libXdmcp
libX11
libXext
libXxf86vm
libXfixes
libXdamage
libdrm
libXi
libICE
libSM
libXt
libXmu
libGL
libXpm
libXaw
libxkbfile
libxkbui
libfontenc
libXfont
libXinerama
libdmx
pixman
libpciaccess
xserver
libXv
libXvMC
xf86-video-intel
xf86-input-keyboard
xf86-input-mouse
