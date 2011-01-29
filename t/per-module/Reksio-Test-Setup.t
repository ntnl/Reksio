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
use lib $Bin .q{/../../lib};

use Reksio::Test::Setup qw( fake_installation );

use Test::More;
# }}}

plan tests =>
    + 2 # fake_installation
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

like( $basedir, qr{/tmp/reksio-unit-test-\d+?/}, q{fake_installation - returns directory});

ok (
    -d $basedir,
    q{fake_instalation - directory has been created}
);

# vim: fdm=marker
