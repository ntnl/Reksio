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
# }}}

my $DB_VERSION = q{v0.1};

unlink $Bin .q{/../t_data/empty_db.sqlite};

system q{sqlite3}, q{-init}, $Bin .q{/../data/sql/}.$DB_VERSION.q{/structure.sql}, $Bin .q{/../t_data/empty_db.sqlite}, q{/* */};

# vim: fdm=marker
