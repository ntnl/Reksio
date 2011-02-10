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

use Reksio::API::Data qw( add_repository );
use Reksio::Test::Setup qw( fake_installation );

use Test::More;
# }}}

plan tests =>
    + 1 # ->new()
;

my $basedir = fake_installation($Bin .q{/../../t_data/});
my $repo1_id = add_repository(name => 'First', vcs=>'GIT', uri=>'git://foo/bar');
my $repo2_id = add_repository(name => 'Other', vcs=>'CVS', uri=>'cvs://bar/baz');

use Reksio::VCS::GIT;

my $vcs_handler = Reksio::VCS::GIT->new(
    uri => q{git://foo/bar},
);

isa_ok($vcs_handler, q{Reksio::VCS::GIT});

# vim: fdm=marker
