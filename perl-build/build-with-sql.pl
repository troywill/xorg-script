#!/usr/bin/perl
use strict;
use warnings;
use XML::Parser;
use XML::SimpleObject;

my $XML_FILE = 'xorg.modules.xml';
my $REPO = 'git://git.freedesktop.org/git';

# Generated from: $ jhbuild list xserver xf86-video-intel xf86-input-keyboard libXft xorg-apps xkeyboard-config 2009-07-24
my @modules = qw (
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
		   xorg-apps
		   xkeyboard-config
		);

# http://www.xml.com/pub/a/2001/04/18/perlxmlqstart1.html
use DBI;
my $database = 'gnu.db';
# unlink($database);
my $dbh = DBI->connect("dbi:SQLite:$database", "", "", {RaiseError => 1, AutoCommit => 1});
# &populate_gnu_software($dbh);

sub populate_gnu_software {
  my $dbh = shift;
  $dbh->do("CREATE TABLE xorg_modules (id INTEGER PRIMARY KEY, name TEXT UNIQUE, repository TEXT, checkout_dir TEXT)");
  #################### Populate table gnu_software ####################
  my $sth_gs = $dbh->prepare("INSERT INTO xorg_modules VALUES (?, ?, ?, ?)");
  $sth_gs->execute( undef,'gcc','GNU Compiler Collection', '4.4.0');
}

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xmlobj = XML::SimpleObject->new( $parser->parsefile($XML_FILE) );

# my $sth_gs = $dbh->prepare("INSERT INTO xorg_modules VALUES (?, ?, ?, ?)");
foreach my $element ($xmlobj->child("moduleset")->children("autotools")) {
  my $id = $element->attribute('id');
  my $branch = $element->child('branch');
  my $repo = $branch->attribute('repo');
  my $module = $branch->attribute('module');
  my $checkoutdir = $branch->attribute('checkoutdir');
  print "$id\t$module\n";
  warn if ( $repo ne 'git.freedesktop.org');

  #     #################### Populate table gnu_software ####################

  #     $sth_gs->execute( undef, $id, $module, $checkoutdir );

  # #    print "foo: ", $element->child('branch')->attribute('repo'), "\n";
}

my $all = $dbh->selectall_arrayref("SELECT * FROM xorg_modules ORDER BY id");
foreach my $row (@$all) {
  my ($id, $name, $repository, $checkout_dir ) = @$row;
  print "$id\t$name\t$repository\t$checkout_dir\n";
  my $command = "mkdir -p $checkout_dir && git clone $REPO/$repository $checkout_dir";
  $command = "git clone $REPO/$repository $checkout_dir";
  print $command, "\n";
  #    system $command;
  #    unlink $checkout_dir;

}

my $sth2 = $dbh->prepare("SELECT repository, checkout_dir FROM xorg_modules where name = ?");
foreach my $module ( @modules ) {
  $sth2->execute( $module );
  my ( $repository, $checkout_dir ) = $sth2->fetchrow();
  my $delimeter = "-----------------------------------------------------------------------------\n";
  print $delimeter;
  my $command = "mkdir -p ~/GIT && cd ~/GIT && git clone $REPO/$repository $checkout_dir";
  $command = "cd ~/GIT/$checkout_dir && git pull";
#  print $command, "\n";
  print "module = $module\nrepository=$repository\n";
#  system("$command");
}

__END__
#### Begin Section: Useful webpages
# http://directory.fsf.org/GNU/ Directory of GNU software
# http://sql-info.de/mysql/examples/Perl-DBI-examples.html
# http://mailliststock.wordpress.com/2007/03/01/sqlite-examples-with-bash-perl-and-python/
# su -c 'aptitude install libdbd-sqlite3-perl' on a Debian system TDW 2009-04-19
# su -c 'perl -MCPAN -e "install DBI"'
# su -c 'perl -MCPAN -e "install DBD::SQLite"'
#### End Section: Useful webpages

my $repository = '/tmp/';
my $stow_dir = '/stow';
my $target_dir = 
  my $su_command = 'sudo';
my $tar_command = 'tar --verbose --extract --file';


&populate_gnu_mirrors($dbh);

# &print_mirrors;
&print_software;

################################################ Subroutines only below this line ############################

#&populate_gnu_contributors($dbh);

sub print_software {
  print "=================================== Table gnu_software =================================\n";
  # $dbh->do("CREATE TABLE gnu_software (id INTEGER PRIMARY KEY, short_name TEXT UNIQUE, name TEXT, latest_version TEXT, date_checked DATE )");
  my $all = $dbh->selectall_arrayref("SELECT * FROM gnu_software ORDER BY short_name");
  foreach my $row (@$all) {
    my ($id, $short_name, $name, $latest_version, $date_checked ) = @$row;
    print "$short_name-$latest_version ($name)\n";
  }
}

  sub print_mirrors {
    #     $dbh->do("CREATE TABLE continent (id INTEGER PRIMARY KEY, name TEXT)");
    #     $dbh->do("CREATE TABLE country (id INTEGER PRIMARY KEY, continent_id INTEGER, name TEXT)");
    #     $dbh->do("CREATE TABLE region (id INTEGER PRIMARY KEY, name TEXT)");
    #     $dbh->do("CREATE TABLE mirror_url (id INTEGER PRIMARY KEY, country_id, region_id, url TEXT, date_checked DATE)");
    my $all = $dbh->selectall_arrayref("SELECT * FROM mirror_url ORDER BY country_id, region_id, url");
    foreach my $row (@$all) {
      my ($id, $country_id, $region_id, $url, $date_checked ) = @$row;
      print "$id\t$country_id\t$region_id\t$url\t$date_checked\n";
    }
  }

  sub populate_gnu_mirrors {
    my $dbh = shift;
    $dbh->do("CREATE TABLE continent (id INTEGER PRIMARY KEY, name TEXT)");
    $dbh->do("CREATE TABLE country (id INTEGER PRIMARY KEY, continent_id INTEGER, name TEXT)");
    $dbh->do("CREATE TABLE region (id INTEGER PRIMARY KEY, name TEXT)");
    $dbh->do("CREATE TABLE mirror_url (id INTEGER PRIMARY KEY, country_id, region_id, url TEXT, date_checked DATE)");

    $dbh->do("INSERT INTO continent VALUES (1, 'Asia')");
    $dbh->do("INSERT INTO continent VALUES (2, 'Africa')");
    $dbh->do("INSERT INTO continent VALUES (3, 'North America')");
    $dbh->do("INSERT INTO continent VALUES (4, 'South America')");
    $dbh->do("INSERT INTO continent VALUES (5, 'Antartica')");
    $dbh->do("INSERT INTO continent VALUES (6, 'Europe')");
    $dbh->do("INSERT INTO continent VALUES (7, 'Australia')");

    # Countries
    $dbh->do("INSERT INTO country VALUES (1, 3, 'United States')");

    #Regions
    $dbh->do("INSERT INTO region VALUES (1, 'Not specified')");
    $dbh->do("INSERT INTO region VALUES (2, 'California')");

    #Urls
    my $date_checked = '2009-04-19';
    my $sth_mu = $dbh->prepare("INSERT INTO mirror_url VALUES (?, ?, ?, ?, ?)");
    $sth_mu->execute(1, 1, 2, 'ftp://mirrors.kernel.org/gnu/', '2009-04-19');
    $sth_mu->execute(2, 1, 2, 'http://mirrors.kernel.org/gnu/', '2009-04-19');
    $sth_mu->execute(3, 1, 2, 'ftp.keystealth.org/pub/gnu/gnu/', '2009-04-19');
    $sth_mu->execute(4, 1, 2, 'ftp://mirrors.usc.edu/pub/gnu/', '2009-04-19');
    $sth_mu->execute(5, 1, 2, 'http://mirrors.usc.edu/pub/gnu/', '2009-04-19');
    $sth_mu->execute(6, 1, 2, 'http://www.alliedquotes.com/mirrors/gnu/gnu/', '2009-04-19');
	
    
    #    $dbh->do("INSERT INTO mirror_url VALUES (1, 1, 2, 'ftp://mirrors.kernel.org/gnu/', '2009-04-19')");
    #    o [22]http://mirrors.kernel.org/gnu/
  }    
exit
  __END__
  GNU mirror list

  * United States
  + California
  o [21]ftp://mirrors.kernel.org/gnu/
  o [22]http://mirrors.kernel.org/gnu/
  o [23]ftp://ftp.keystealth.org/pub/gnu/gnu/
  o [24]ftp://mirrors.usc.edu/pub/gnu/
  o [25]http://mirrors.usc.edu/pub/gnu/
  o [26]http://www.alliedquotes.com/mirrors/gnu/gnu/
  + Colorado
  o [27]http://cudlug.cudenver.edu/GNU/gnu/
  + Idaho
  o [28]http://mirror.its.uidaho.edu/pub/gnu/
  o [29]ftp://mirror.its.uidaho.edu/gnu/
  o [30]rsync://mirror.its.uidaho.edu/gnu
  + Illinois
  o [31]http://ftp.gnu.mirrors.hoobly.com/gnu/
  o [32]ftp://mirror.anl.gov/pub/gnu/
  o [33]http://mirror.anl.gov/pub/gnu/
  o [34]http://www.netgull.com/gnu/
  o [35]http://astromirror.uchicago.edu/gnu/
  + Massachusetts
  o [36]ftp://aeneas.mit.edu/pub/gnu/
  + Michigan
  o [37]http://ftp.wayne.edu/pub/gnu/
  + New York
  o [38]http://mirror.cinquix.com/pub/gnu/
  o [39]ftp://mirror.cinquix.com/pub/gnu/
  o [40]mirror.cinquix.com::gnuftp
  + North Carolina
  o [41]http://mirrors.ibiblio.org/pub/mirrors/gnu/ftp/gnu/
  o [42]rsync://mirrors.ibiblio.org::gnuftp/
  + Pennsylvania
  o [43]ftp://ftp.club.cc.cmu.edu/gnu/
  o [44]http://ftp.club.cc.cmu.edu/pub/gnu/
  + Texas
  o [45]http://www.gnu.potius.org/
  o [46]http://gnu.inetbridge.net/
  * The Americas (other than the U.S.)
  + Brazil
  o [47]ftp://ftp.unicamp.br/pub/gnu/
  + Canada
  o [48]ftp://mirror.csclub.uwaterloo.ca/gnu/
  o [49]http://mirror.csclub.uwaterloo.ca/gnu/
  o [50]ftp://gnu.mirror.iweb.com/gnu/
  o [51]http://gnu.mirror.iweb.com/gnu/
  o [52]rsync://gnu.mirror.iweb.com/gnu
  + Costa Rica
  o [53]ftp://mirrors.ucr.ac.cr/GNU/gnu
  o [54]http://mirrors.ucr.ac.cr/GNU/gnu
  o [55]rsync://mirrors.ucr.ac.cr/GNU/gnu
  * Africa
  + South Africa
  o [56]ftp://ftp.is.co.za/mirror/ftp.gnu.org/gnu
  * Asia
  + Japan
  o [57]http://core.ring.gr.jp/pub/GNU/
  o [58]ftp://ftp.ring.gr.jp/pub/GNU/
  + Korea
  o [59]ftp://ftp.kaist.ac.kr/gnu/
  + Malaysia
  o [60]ftp://mirror.publicns.net/pub/gnu/gnu/
  o [61]http://mirror.publicns.net/pub/gnu/gnu/
  + Taiwan
  o [62]ftp://ftp.ntu.edu.tw/pub/gnu/gnu/
  o [63]ftp://ftp.twaren.net/Unix/GNU/gnu/
  o [64]http://ftp.twaren.net/Unix/GNU/gnu/
  + Thailand
  o [65]http://ftp.thaios.net/gnu/
  + Vietnam
  o [66]http://gnu.billfett.com/gnu/
  o [67]http://gnu.07vn.com/gnu/
  o [68]ftp://mirror-fpt-telecom.fpt.net/gnu/
  o [69]http://mirror-fpt-telecom.fpt.net/gnu/
  * Europe
  + Austria
  o [70]ftp://gd.tuwien.ac.at/gnu/gnusrc/
  o [71]http://gd.tuwien.ac.at/gnu/gnusrc/
  + Belgium
  o [72]ftp://ftp.easynet.be/gnu/
  o [73]http://ftp.easynet.be/ftp/gnu/
  + Czech Republic
  o [74]ftp://ftp.sh.cvut.cz/MIRRORS/gnu/pub/gnu/
  o [75]http://ftp.sh.cvut.cz/MIRRORS/gnu/pub/gnu/
  + Denmark
  o [76]http://ftp.download-by.net/gnu/gnu/
  + Finland
  o [77]ftp://ftp.funet.fi/pub/gnu/prep/
  + France
  o [78]ftp://ftp.ironie.org/ftp.gnu.org/pub/gnu/
  o [79]http://gnu.mirror.ironie.org/pub/gnu/
  o [80]ftp://mirror.cict.fr/gnu/
  + Germany
  o [81]ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.gnu.
  org/
  o [82]ftp://ftp.cs.tu-berlin.de/pub/gnu/
  o [83]ftp://ftp.informatik.rwth-aachen.de/pub/gnu/
  o [84]ftp://ftp.cw.net/pub/gnu/
  o [85]ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.gnu.
  org/
  o [86]ftp://ftp.cw.net/pub/gnu/
  o [87]http://www.de-mirrors.de/gnuftp/
  o [88]http://www.very-clever.com/download/gnu/
  o [89]http://mirrors.zerg.biz/gnu/
  + Greece
  o [90]ftp://ftp.duth.gr/pub/gnu/
  o [91]ftp://ftp.ntua.gr/pub/gnu/
  o [92]ftp://ftp.cc.uoc.gr/mirrors/gnu/
  o [93]http://ftp.cc.uoc.gr/mirrors/gnu/
  + Ireland
  o [94]ftp://ftp.esat.net/pub/gnu/
  o [95]ftp://ftp.heanet.ie/mirrors/ftp.gnu.org/gnu/
  o [96]http://ftp.heanet.ie/mirrors/ftp.gnu.org/gnu/
  + Netherlands
  o [97]ftp://ftp.mirror.nl/pub/mirror/gnu/
  o [98]ftp://ftp.nluug.nl/pub/gnu/
  o [99]http://gnu.cyclingchampion.com/gnu/
  + Norway
  o [100]ftp://ftp.uninett.no/pub/gnu/
  + Poland
  o [101]ftp://ftp.task.gda.pl/pub/gnu/
  o [102]ftp://sunsite.icm.edu.pl/pub/gnu/
  o [103]ftp://ftp.piotrkosoft.net/pub/mirrors/ftp.gnu.org/g
  nu/
  o [104]http://piotrkosoft.net/pub/mirrors/ftp.gnu.org/gnu/
  + Portugal
  o [105]ftp://mirrors.nfsi.pt/pub/gnu/
  o [106]http://mirrors.nfsi.pt/gnu/
  + Russia
  o [107]http://mirror.prvtgeo.com/ftp.gnu.org/
  o [108]rsync://mirror.prvtgeo.com/gnuftp/
  o [109]ftp://ftp.chg.ru/pub/gnu/
  + Slovenia
  o [110]http://gnu.wsection.com/
  o [111]http://mirror.lihnidos.org/GNU/ftp/
  o [112]http://mirror.lihnidos.org/GNU/alpha/
  + Spain
  o [113]ftp://ftp.gul.es/gnu/pub/gnu/
  o [114]http://ftp.gul.es/gnu/pub/gnu/
  + Sweden
  o [115]ftp://ftp.isy.liu.se/pub/gnu/
  o [116]ftp://ftp.sunet.se/pub/gnu/
  o [117]ftp://ftp.df.lth.se/pub/ftp.gnu.org/pub/gnu/
  o [118]http://ftp.df.lth.se/pub/ftp.gnu.org/pub/gnu/
  + Switzerland
  o [119]ftp://sunsite.cnlab-switch.ch/mirror/gnu/
  + Turkey
  o [120]ftp://ftp.ulak.net.tr/gnu/gnu/
  + UK
  o [121]ftp://www.mirrorservice.org/sites/ftp.gnu.org/
  o [122]http://www.mirrorservice.org/sites/ftp.gnu.org/
  + Ukraine
  o [123]ftp://ftp.gnu.org.ua/gnu/

  Add your mirror to this list

  We welcome and appreciate more mirrors. If you are able to provide
  one, please see [124]http://www.gnu.org/server/mirror.html for
  information and instructions.

  TeX and how to obtain it

  TeX is a document formatter that is used by the FSF for all its
  documentation. You will need it if you want to make printed manuals.

  TeX is freely redistributable. You can get it over the Internet or on
  physical media. See [125]http://tug.org/texlive.

  Supporting the free software movement

  If you agree with the free software ideals we espouse, or just like
  GNU software, please consider supporting the Free Software Foundation,
  by joining as an associate member ([126]http://fsf.org/join), making a
  donation ([127]http://www.fsf.org/associate/support_freedom/donate),
  or buying books or promotional items ([128]http://shop.fsf.org). For
  still other ways to contribute to GNU, both technical and
  non-technical, see [129]http://www.gnu.org/help.

  Your support will help ensure the future of free software.

  [130]back to top

  Please send FSF & GNU inquiries to [131]gnu@gnu.org. There are also
  [132]other ways to contact the FSF.
  Please send broken links and other corrections or suggestions to
  [133]webmasters@gnu.org.

  Please see the [134]Translations README for information on
  coordinating and submitting translations of this article.

  Copyright � 1997, 1998, 1999, 2003, 2004, 2005, 2006, 2007, 2008, 2009
  Free Software Foundation, Inc.,


  51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

  Verbatim copying and distribution of this entire article is permitted
  worldwide without royalty in any medium provided this notice is
  preserved.

 Updated: $Date: 2009/04/12 16:23:45 $

  Translations of this page

  * [135]English [en]

  References

  1. file://localhost/home/troy/git/stow/experimental/ftp.html #content
  2. file://localhost/home/troy/git/stow/experimental/ftp.html #searcher
  3. file://localhost/home/troy/git/stow/experimental/ftp.html #translations
  4. file://localhost/home/troy/git/stow/experimental/ftp.html #navigation
  5. file://localhost/
  6. file://localhost/gnu/gnu.html
  7. file://localhost/philosophy/philosophy.html
  8. file://localhost/licenses/licenses.html
  9. file://localhost/software/software.html
  10. file://localhost/help/help.html
  11. https://www.fsf.org/associate/support_freedom?referrer=4052
  12. http://www.gnu.org/order/ftp.html
  13. mailto:gnu@gnu.org
  14. ftp://ftp.gnu.org/
  15. ftp://ftp.gnu.org/
  16. http://ftpmirror.gnu.org/
  17. http://gnu.org/software/gzip
  18. http://bzip.org/
  19. http://www.gnupg.org/documentation/faqs.en.html #q4.19
  20. http://www.gnu.org/directory
  21. ftp://mirrors.kernel.org/gnu/
  22. http://mirrors.kernel.org/gnu/
  23. ftp://ftp.keystealth.org/pub/gnu/gnu/
  24. ftp://mirrors.usc.edu/pub/gnu/
  25. http://mirrors.usc.edu/pub/gnu/
  26. http://www.alliedquotes.com/mirrors/gnu/gnu/
  27. http://cudlug.cudenver.edu/GNU/gnu/
  28. http://mirror.its.uidaho.edu/pub/gnu/
  29. ftp://mirror.its.uidaho.edu/gnu/
  30. rsync://mirror.its.uidaho.edu/gnu
  31. http://ftp.gnu.mirrors.hoobly.com/gnu/
  32. ftp://mirror.anl.gov/pub/gnu/
  33. http://mirror.anl.gov/pub/gnu/
  34. http://www.netgull.com/gnu/
  35. http://astromirror.uchicago.edu/gnu/
  36. ftp://aeneas.mit.edu/pub/gnu/
  37. http://ftp.wayne.edu/pub/gnu/
  38. http://mirror.cinquix.com/pub/gnu/
  39. ftp://mirror.cinquix.com/pub/gnu/
  40. ftp://mirror.cinquix.com/
  41. http://mirrors.ibiblio.org/pub/mirrors/gnu/ftp/gnu/
  42. rsync://mirrors.ibiblio.org/
  43. ftp://ftp.club.cc.cmu.edu/gnu/
  44. http://ftp.club.cc.cmu.edu/pub/gnu/
  45. http://www.gnu.potius.org/
  46. http://gnu.inetbridge.net/
  47. ftp://ftp.unicamp.br/pub/gnu/
  48. ftp://mirror.csclub.uwaterloo.ca/gnu/
  49. http://mirror.csclub.uwaterloo.ca/gnu/
  50. ftp://gnu.mirror.iweb.com/gnu/
  51. http://gnu.mirror.iweb.com/gnu/
  52. rsync://gnu.mirror.iweb.com/gnu
  53. ftp://mirrors.ucr.ac.cr/GNU/gnu
  54. http://mirrors.ucr.ac.cr/GNU/gnu
  55. rsync://mirrors.ucr.ac.cr/GNU/gnu
  56. ftp://ftp.is.co.za/mirror/ftp.gnu.org/gnu
  57. http://core.ring.gr.jp/pub/GNU/
  58. ftp://ftp.ring.gr.jp/pub/GNU/
  59. ftp://ftp.kaist.ac.kr/gnu/
  60. ftp://mirror.publicns.net/pub/gnu/gnu/
  61. http://mirror.publicns.net/pub/gnu/gnu/
  62. ftp://ftp.ntu.edu.tw/pub/gnu/gnu/
  63. ftp://ftp.twaren.net/Unix/GNU/gnu/
  64. http://ftp.twaren.net/Unix/GNU/gnu/
  65. http://ftp.thaios.net/gnu/
  66. http://gnu.billfett.com/gnu/
  67. http://gnu.07vn.com/gnu/
  68. ftp://mirror-fpt-telecom.fpt.net/gnu/
  69. http://mirror-fpt-telecom.fpt.net/gnu/
  70. ftp://gd.tuwien.ac.at/gnu/gnusrc/
  71. http://gd.tuwien.ac.at/gnu/gnusrc/
  72. ftp://ftp.easynet.be/gnu/
  73. http://ftp.easynet.be/ftp/gnu/
  74. ftp://ftp.sh.cvut.cz/MIRRORS/gnu/pub/gnu/
  75. http://ftp.sh.cvut.cz/MIRRORS/gnu/pub/gnu/
  76. http://ftp.download-by.net/gnu/gnu/
  77. ftp://ftp.funet.fi/pub/gnu/prep/
  78. ftp://ftp.ironie.org/ftp.gnu.org/pub/gnu/
  79. http://gnu.mirror.ironie.org/pub/gnu/
  80. ftp://mirror.cict.fr/gnu/
  81. ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.gnu.org/
  82. ftp://ftp.cs.tu-berlin.de/pub/gnu/
  83. ftp://ftp.informatik.rwth-aachen.de/pub/gnu/
  84. ftp://ftp.cw.net/pub/gnu/
  85. ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.gnu.org/
  86. ftp://ftp.cw.net/pub/gnu/
  87. http://www.de-mirrors.de/gnuftp/
  88. http://www.very-clever.com/download/gnu/
  89. http://mirrors.zerg.biz/gnu/
  90. ftp://ftp.duth.gr/pub/gnu/
  91. ftp://ftp.ntua.gr/pub/gnu/
  92. ftp://ftp.cc.uoc.gr/mirrors/gnu/
  93. http://ftp.cc.uoc.gr/mirrors/gnu/
  94. ftp://ftp.esat.net/pub/gnu/
  95. ftp://ftp.heanet.ie/mirrors/ftp.gnu.org/gnu/
  96. http://ftp.heanet.ie/mirrors/ftp.gnu.org/gnu/
  97. ftp://ftp.mirror.nl/pub/mirror/gnu/
  98. ftp://ftp.nluug.nl/pub/gnu/
  99. http://gnu.cyclingchampion.com/gnu/
  100. ftp://ftp.uninett.no/pub/gnu/
  101. ftp://ftp.task.gda.pl/pub/gnu/
  102. ftp://sunsite.icm.edu.pl/pub/gnu/
  103. ftp://ftp.piotrkosoft.net/pub/mirrors/ftp.gnu.org/gnu/
  104. http://piotrkosoft.net/pub/mirrors/ftp.gnu.org/gnu/
  105. ftp://mirrors.nfsi.pt/pub/gnu/
  106. http://mirrors.nfsi.pt/gnu/
  107. http://mirror.prvtgeo.com/ftp.gnu.org/
  108. rsync://mirror.prvtgeo.com/gnuftp/
  109. ftp://ftp.chg.ru/pub/gnu/
  110. http://gnu.wsection.com/
  111. http://mirror.lihnidos.org/GNU/ftp/
  112. http://mirror.lihnidos.org/GNU/alpha/
  113. ftp://ftp.gul.es/gnu/pub/gnu/
  114. http://ftp.gul.es/gnu/pub/gnu/
  115. ftp://ftp.isy.liu.se/pub/gnu/
  116. ftp://ftp.sunet.se/pub/gnu/
  117. ftp://ftp.df.lth.se/pub/ftp.gnu.org/pub/gnu/
  118. http://ftp.df.lth.se/pub/ftp.gnu.org/pub/gnu/
  119. ftp://sunsite.cnlab-switch.ch/mirror/gnu/
  120. ftp://ftp.ulak.net.tr/gnu/gnu/
  121. ftp://www.mirrorservice.org/sites/ftp.gnu.org/
  122. http://www.mirrorservice.org/sites/ftp.gnu.org/
  123. ftp://ftp.gnu.org.ua/gnu/
  124. http://www.gnu.org/server/mirror.html
  125. http://tug.org/texlive
  126. http://fsf.org/join
  127. http://www.fsf.org/associate/support_freedom/donate
  128. http://shop.fsf.org/
  129. http://www.gnu.org/help
  130. file://localhost/home/troy/git/stow/experimental/ftp.html #header
  131. mailto:gnu@gnu.org
  132. file://localhost/contact/
  133. mailto:webmasters@gnu.org
  134. file://localhost/server/standards/README.translations.html
  135. file://localhost/order/ftp.html
