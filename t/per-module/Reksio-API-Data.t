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

use Reksio::API::Data qw(
    add_repository
    get_repository
    get_repositories
    delete_repository

    add_build
    get_build
    get_builds
    delete_build

    add_revision
    get_revision
    get_revisions
    delete_revision

    add_result
    get_result
    get_results
    delete_result
);

plan tests =>
    + 2 # add_repository
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $r1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');
is($r1_id, 1, q{add_repository (1/2)});

my $r2_id = add_repository(name => 'Second', vcs=>'GIT', uri=>'https://foo/bar.git');
is($r2_id, 2, q{add_repository (2/2)});


# vim: fdm=marker
