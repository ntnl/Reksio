#!/usr/bin/perl
################################################################################
# 
# Reksio - continuous integration and testing server
#
# Copyright (C) 2011 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://reksio-project.org/
# 
################################################################################
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../lib};

use File::Slurp qw( write_file );
# }}}

# Note:
#   This is a tem. script to automate documentation integration with website.
#
#   "It's full of hacks" ;)

my $ph;
open $ph, q{-|}, q{find}, $Bin .q{/../lib/}, q{-name}, q{*.pm};
my @files = <$ph>;
close $ph;

my %packages;
foreach my $file (@files) {
    chomp $file;

    my ( $package ) = ($file =~ m{dev/\.\./lib/(.+?)\.pm}s );
    $package =~ s{/}{::}sg;

    #print "Processing $package\n";

    $packages{$package} = $file;
}

foreach my $package (sort keys %packages) {
    print "Procesing: $package\n";

    my $file = $packages{$package};

    open $ph, q{-|}, q{pod2bbcode}, $file;
    my $bbcode = join q{}, <$ph>;
    close $ph;

    if (not $bbcode) {
        print "  Has no doc.\n";
        next;
    }
    
    $bbcode =~ s{\[(.+?)\]\[\/\1\]}{}sg;

    $bbcode =~ s{\[size=5\](.+?)\[\/size\]}{\[h1\]$1\[\/h1\]}sg;
    $bbcode =~ s{\[size=4\](.+?)\[\/size\]}{\[h2\]$1\[\/h2\]}sg;
    $bbcode =~ s{\[size=3\](.+?)\[\/size\]}{\[h3\]$1\[\/h3\]}sg;
    $bbcode =~ s{\[size=2\](.+?)\[\/size\]}{\[h4\]$1\[\/h4\]}sg;
    $bbcode =~ s{\[size=1\](.+?)\[\/size\]}{\[h5\]$1\[\/h5\]}sg;

    $bbcode =~ s{\[list\]}{}sg;
    $bbcode =~ s{\[\/list\]}{}sg;

    $bbcode =~ s{\[\*\](.+?)$}{\n\[b\]* \[i\]$1\[\/i\]\[\/b\]}smg;

    my ( $title ) = ( $bbcode =~ m{NAME\[\/h1\]\n(.+?)\n}s );

    if (not $title) {
        $title = q{Reksio documentation};
    }

#    print $bbcode;

    my $bbfile = $package.q{.bbcode};
    $bbfile =~ s{::}{-}sg;

    print "  Putting in $bbfile\n";
    
    write_file($bbfile, $title .qq{\n\n}. $package .qq{\n\n}. $bbcode);
}

# vim: fdm=marker
