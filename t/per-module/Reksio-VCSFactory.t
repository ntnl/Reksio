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

use Reksio::Test::Setup qw( fake_repository );

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 1 # spawn GIT repo handler
;

use Reksio::VCSFactory;

my $repo_path = fake_repository($Bin);

my $vcs_handler = Reksio::VCSFactory::make('GIT', $repo_path);

isa_ok($vcs_handler, q{Reksio::VCS::GIT});

# vim: fdm=marker
