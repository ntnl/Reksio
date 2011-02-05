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
use Test::Output;
# }}}

use Reksio::Cmd::DelRepo;

plan tests =>
    + 1 # run with no params
    + 1 # check --help
    + 1 # check --version
    + 2 # add a repo
    + 2 # adding repo with existing name is not possible
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $r1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');

my $exit_code;

stdout_like {
    $exit_code = Reksio::Cmd::DelRepo::main(),
} qr{^Usage}s, q{run with no parameters};
stdout_like {
    $exit_code = Reksio::Cmd::DelRepo::main('--help'),
} qr{^Usage}s, q{run with --help};
stdout_like {
    $exit_code = Reksio::Cmd::DelRepo::main('--version'),
} qr{version}s, q{run with --version};


stdout_like {
    $exit_code = Reksio::Cmd::DelRepo::main('--repo=First'),
} qr{Repository deleted}s, q{delete - clean exit (1/2)};

is(
    $exit_code,
    0,
    q{delete - exit code (2/2)},
);



stderr_like {
    $exit_code = Reksio::Cmd::DelRepo::main('--repo=First'),
} qr{Repository .+? does not exist\.}s, q{deny - not exists - clean exit (1/2)};

is(
    $exit_code,
    1,
    q{deny - not exists - clean exit (2/2)},
);

# vim: fdm=marker
