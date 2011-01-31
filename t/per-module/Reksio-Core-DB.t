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

use Reksio::Core::DB;

plan tests =>
    + 2 # get_dbh
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $dbh = Reksio::Core::DB::get_dbh();

isa_ok($dbh, q{DBI::db}, q{get_dbh returns db handler.});

is(Reksio::Core::DB::get_dbh(), $dbh, q{get_dbh returns the same handler, when asked again.});

# vim: fdm=marker
