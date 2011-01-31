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
use lib $Bin .q{/../lib/}; # FIXME: Should not be necessarily.

my $VERSION = '0.1.0';

use Reksio::Cmd::ScheduleBuild;
# }}}

exit Reksio::Cmd::ScheduleBuild::main(@ARGV);

# vim: fdm=marker
