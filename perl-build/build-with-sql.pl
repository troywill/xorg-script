#!/usr/bin/perl
use warnings;
use strict;
use XML::Parser;
use XML::SimpleObject;
use DBI;
#### Written by Troy Will <troydwill@gmail.com> July 2009

# +- Begin Reference Section -----------------------------+
# http://www.xml.com/pub/a/2001/04/18/perlxmlqstart1.html |
# Location of tarballs:
# http://www.nathancoulson.com/proj_eee.shtml ( Has kernel config info )
# http://www.nathancoulson.com/proj/eee/config-2.6.25.4-2 ( kernel config info )
# http://perpetual-notion.blogspot.com/2008/07/gentoo-eee-pc-black-screen-on-resume.html
# http://www.easysoft.com/developer/languages/perl/dbd_odbc_tutorial_part_2.html
# http://dri.sourceforge.net/doc/DRIuserguide.html
# http://perl.jonallen.info
# +- End Reference Section -------------------------------+

# +- Begin User Defined Variable Section -----------------+
my $XML_FILE = 'xorg.modules.091013.xml';
my $DATABASE = 'xorg.db';
my $SQL_MODULE_TABLE = 'xorg_modules';
my $GIT_BASE = "$ENV{'HOME'}/GIT";
# +- End User Defined Variable Section -------------------+

#### Begin General Variable Section #####################################################################
my $REPO = 'git://git.freedesktop.org/git';
my @xorg_modules_in_build_order = &return_xorg_modules_in_build_order; # This array is the list of X.Org modules to build in sequential order
my $DBH = DBI->connect("dbi:SQLite:$DATABASE", "", "", {RaiseError => 1, AutoCommit => 1});
#### End General Variable Section #######################################################################

#### Main Program ######## Main Program ######## Main Program ######## Main Program ######## Main Program ####
# &parse_xorg_xml_and_insert; # Take XML data from X.Org and place into an SQL database table
my @array_of_array_references = &generate_array_from_sql; # Read SQL table data built with &parse_xorg_xml_and_insert
# &read_xorg_modules_table_and_print; # Print every module, not just ones for Asus Eee PC
# &do_git_checkout(@array_of_array_references);
&do_git_pull(@array_of_array_references);
# &print_build_order(@array_of_array_references);
&do_build(@array_of_array_references);

#### Place only subroutines below this line ( Troy Will, TDW ) ###

sub parse_xorg_xml_and_insert {
  ## Parse the X.org XML modules file and insert into SQL table
  my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
  my $xmlobj = XML::SimpleObject->new( $parser->parsefile($XML_FILE) );
  # Create the SQL table
  $DBH->do("DROP TABLE IF EXISTS $SQL_MODULE_TABLE");
  $DBH->do("CREATE TABLE $SQL_MODULE_TABLE (id INTEGER PRIMARY KEY, name TEXT UNIQUE, repository TEXT, checkout_dir TEXT)");

  my $sth_gs = $DBH->prepare("INSERT INTO $SQL_MODULE_TABLE VALUES (?, ?, ?, ?)");

  foreach my $element ($xmlobj->child("moduleset")->children("autotools")) {
    my $id = $element->attribute('id');
    my $branch = $element->child('branch');
    my $repo = $branch->attribute('repo');
    my $module = $branch->attribute('module');
    my $checkoutdir = $branch->attribute('checkoutdir');
    $sth_gs->execute( undef, $id, $module, $checkoutdir );
  }
}

# # print modules and build directories, may want to build individually
# sub print_build_order {
#   my @AoA = @_;
#   my $counter = 0;
#   foreach my $row ( @AoA ) {
#     $counter++;
#     my ( $module, $repository, $checkout_dir ) = @$row;
#     if ( $checkout_dir eq '' ) {
#       $repository =~ m/\/(.*?)$/;
#       # Change mesa/drm to drm, mesa/mesa to mesa
#       $checkout_dir = $1;
#     }
#     my $repo_dir = "$GIT_BASE/$checkout_dir";
#     print "<tr><td>$counter</td><td>$module</td><td>$repo_dir</td></tr>\n";
#   }
# }

sub do_build {
  my @AoA = @_;
  my $counter = 0;
  foreach my $row ( @AoA ) {
    $counter++;
    my ( $module, $repository, $checkout_dir ) = @$row;

    if ( $checkout_dir eq '' ) {
      $repository =~ m/\/(.*?)$/;
      # Change mesa/drm to drm, mesa/mesa to mesa (TDW 2009)
      $checkout_dir = $1;
    }
    my $repo_dir = "$GIT_BASE/$checkout_dir";
    my $command = "cd $repo_dir && git pull";
    print "Package $counter: $module, shall I build (y/n)?";
    my $answer = <STDIN>;
    chomp ($answer);
    if ( $answer eq 'y' ) {
      write_build_script ( $repo_dir, $module );
    } else {
      print "Skipping $module\n";
    }
    sub write_build_script {
      my ( $repo_dir, $module ) = @_;
      my $formated_counter = sprintf('%03d', $counter);
      my $stow_dir = "X.$formated_counter.$module.14";
      print "chdir $repo_dir; ";
      chdir $repo_dir || die "Unable to chdir $repo_dir";
      my $script = <<END;
#!/bin/bash
./autogen.sh
./configure --prefix=/usr
make
sudo make DESTDIR=/stow/$stow_dir install
sudo stow -v $stow_dir;
END
      open ( OUT, ">stow-$module.sh");
      print OUT $script;
      close OUT;
      system("sh ./stow-$module.sh");
      print "\n [$module] END\n";
    }
  }
}

sub do_git_checkout {
  # Call this function with the array of repository data as an argument
  # Do a git pull on each module in the array
  system("mkdir -p $GIT_BASE");
  my @AoA = @_;
  foreach my $row ( @AoA ) {
    print "==> @$row\n"; sleep 1;
    my ($module, $repository, $checkout_dir ) = @$row;
    $checkout_dir = '' if !defined($checkout_dir);
    my $command = "cd $GIT_BASE && git clone $REPO/$repository $checkout_dir";
    print $command, "\n";
    system $command;
  }
}

sub read_xorg_modules_table_and_print {
  my $all = $DBH->selectall_arrayref("SELECT * FROM $SQL_MODULE_TABLE ORDER BY id");
  foreach my $row (@$all) {
    my ($id, $name, $repository, $checkout_dir ) = @$row;
    print "$id\t$name\t$repository\t$checkout_dir\n";
  }
}

sub generate_array_from_sql {
  # Introduction ----------------------------------------------------#
  # We have have taken XML data and placed it into an SQL table
  # We want to pull out the data from the SQL table in the package build order.
  # 
  #------------------------------------------------------------------#
  my @array_of_array_references;
  my $sth2 = $DBH->prepare("SELECT repository, checkout_dir FROM $SQL_MODULE_TABLE where name = ?");
  foreach my $module ( @xorg_modules_in_build_order ) {
    $sth2->execute( $module );
    my ( $repository, $checkout_dir ) = $sth2->fetchrow();
    $checkout_dir = '' if !defined $checkout_dir;
    push (@array_of_array_references, [ $module, $repository, $checkout_dir ]);
  }
  return @array_of_array_references;
}

sub do_git_pull {
  my @AoA = @_;
  system("mkdir --parent $GIT_BASE"); # Does Perl have a mkdir --parent equivalent?
  foreach my $row ( @AoA ) {
    my ( $module, $repository, $checkout_dir ) = @$row;
    if ( $checkout_dir eq '' ) {
      print "$repository\n";
      $repository =~ m/\/(.*?)$/;
      # Change mesa/drm to drm, mesa/mesa to mesa
      $checkout_dir = $1;
    }
    my $repo_dir = "$GIT_BASE/$checkout_dir";
    my $command = "cd $repo_dir && git pull";
    system $command;
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
					 mkfontscale
					 libXfont
					 libXinerama
					 libdmx
					 libXtst
					 libXRes
					 pixman
					 libpciaccess
					 xserver
					 libXv
					 libXvMC
					 xf86-video-intel
					 xf86-input-keyboard
					 xkbcomp
					 xkeyboard-config
					 iceauth
					 luit
					 libXrender
					 rendercheck
					 scripts
					 setxkbmap
					 smproxy
					 twm
					 fontconfig
					 libXft
					 x11perf
					 xauth
					 xdpyinfo
					 xdriinfo
					 xev
					 xeyes
					 xhost
					 xinit
					 xinput
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
				      );
}
