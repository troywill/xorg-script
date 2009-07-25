#!/usr/bin/perl
use warnings;
use strict;
use XML::Parser;
use XML::SimpleObject;
use DBI;

# +- Begin Reference Section -----------------------------+
# http://www.xml.com/pub/a/2001/04/18/perlxmlqstart1.html |
# Location of tarballs:
# http://www.nathancoulson.com/proj_eee.shtml
# http://perpetual-notion.blogspot.com/2008/07/gentoo-eee-pc-black-screen-on-resume.html
# http://www.easysoft.com/developer/languages/perl/dbd_odbc_tutorial_part_2.html
# +- End Reference Section -------------------------------+

# +- Begin User Defined Variable Section -----------------+
my $XML_FILE = 'xorg.modules.xml';                        #
my $DATABASE = 'xorg.db';                                 #
# +- End User Defined Variable Section -------------------+

#### Begin General Variable Section #######################
my $REPO = 'git://git.freedesktop.org/git';
my @xorg_modules_in_build_order = &return_xorg_modules_in_build_order; # This array is the list of X.Org modules to build in sequential order
my $DBH = DBI->connect("dbi:SQLite:$DATABASE", "", "", {RaiseError => 1, AutoCommit => 1});
#### End General Variable Section #########################

#### Main Program ######## Main Program ######## Main Program ######## Main Program ######## Main Program ####
# &parse_xorg_xml_and_insert;
# &read_xorg_modules_table_and_print;
# &read_module_data_from_sql;
# &two_dimensional_matrix_test;
&generate_array_from_sql;
# my @array_of_array_references = &generate_array_from_sql;

#### Place only subroutines below this line ( Troy Will, TDW )

sub generate_array_from_sql {
    # Introduction ----------------------------------------------------#
    # We have have taken XML data and placed it into an SQL table
    # We want to pull out the data from the SQL table in the package build order.
    # 
    #------------------------------------------------------------------#
    my @array_of_array_references;
    my $sth2 = $DBH->prepare("SELECT repository, checkout_dir FROM xorg_modules where name = ?");
    foreach my $module ( @xorg_modules_in_build_order ) {
	$sth2->execute( $module );
	my ( $repository, $checkout_dir ) = $sth2->fetchrow();
	$checkout_dir = '' if !defined $checkout_dir;
	push (@array_of_array_references, [ $module, $repository, $checkout_dir ]);
    }
    foreach my $row (@array_of_array_references) {
	my ($module, $repository, $checkout_dir) = ($row->[0], $row->[1], $row->[2]);
	print "$module, $repository, $checkout_dir\n";
    }

}

sub parse_xorg_xml_and_insert {
  ## Parse the X.org XML modules file and insert into SQL table
  my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
  my $xmlobj = XML::SimpleObject->new( $parser->parsefile($XML_FILE) );
  # Create the SQL table
  $DBH->do("DROP TABLE IF EXISTS xorg_modules");
  $DBH->do("CREATE TABLE xorg_modules (id INTEGER PRIMARY KEY, name TEXT UNIQUE, repository TEXT, checkout_dir TEXT)");

  my $sth_gs = $DBH->prepare("INSERT INTO xorg_modules VALUES (?, ?, ?, ?)");

  foreach my $element ($xmlobj->child("moduleset")->children("autotools")) {
    my $id = $element->attribute('id');
    my $branch = $element->child('branch');
    my $repo = $branch->attribute('repo');
    my $module = $branch->attribute('module');
    my $checkoutdir = $branch->attribute('checkoutdir');
    $sth_gs->execute( undef, $id, $module, $checkoutdir );
  }
}

sub two_dimensional_matrix_test {
    my @matrix = (
	['a', 'b', 'c'],
	['d', 'e', 'f']
	); # @matrix is an array with two references to arrays
    foreach my $row (@matrix) {
	print "$row->[0]\n";
    }
}    

sub read_module_data_from_sql {
  my $sth2 = $DBH->prepare("SELECT repository, checkout_dir FROM xorg_modules where name = ?");
  foreach my $module ( @xorg_modules_in_build_order ) {
    $sth2->execute( $module );
    my ( $repository, $checkout_dir ) = $sth2->fetchrow();
    my $command = "mkdir -p ~/GIT && cd ~/GIT && git clone $REPO/$repository $checkout_dir";
    $command = "cd ~/GIT/$checkout_dir && git pull";
    #  system("$command");
  }
}

sub read_xorg_modules_table_and_print {
  my $all = $DBH->selectall_arrayref("SELECT * FROM xorg_modules ORDER BY id");
  foreach my $row (@$all) {
    my ($id, $name, $repository, $checkout_dir ) = @$row;
    print "$id\t$name\t$repository\t$checkout_dir\n";
    my $command = "mkdir -p $checkout_dir && git clone $REPO/$repository $checkout_dir";
    $command = "git clone $REPO/$repository $checkout_dir";
    print $command, "\n";
    #    system $command;
    #    unlink $checkout_dir;
  }
}

sub return_xorg_modules_in_build_order {
# Generated from: $ jhbuild list xserver xf86-video-intel xf86-input-keyboard libXft xorg-apps xkeyboard-config 2009-07-24
# Removed xorg-protos xorg-apps because they are meta packages

    my @xorg_modules_in_build_order = qw (
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
		   libXrender
		   fontconfig
		   libXft
		   iceauth
		   luit
		   rendercheck
		   scripts
		   setxkbmap
		   smproxy
		   twm
		   x11perf
		   xauth
		   libXtst
		   xdpyinfo
		   xdriinfo
		   xev
		   xeyes
		   xhost
		   xinit
		   xinput
		   xkbcomp
		   xkill
		   xlogo
		   xlsatoms
		   xlsclients
		   xmodmap
		   xprop
		   libXrandr
		   xrandr
		   xrdb
		   xset
		   bitmaps
		   xsetroot
		   xvinfo
		   xwd
		   xwininfo
		   xwud
		   xkeyboard-config
		);
}
