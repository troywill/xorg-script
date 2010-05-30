#!/usr/bin/env perl
use warnings;
use strict;


system("sudo X -configure &");
sleep 3;
system("sudo killall X");
system("sudo X -retro -config ~/xorg.conf.new &");
sleep 6;
system("sudo killall X");
