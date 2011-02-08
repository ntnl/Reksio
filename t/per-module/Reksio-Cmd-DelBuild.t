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

use Reksio::API::Data qw( add_repository add_build );
use Reksio::Test::Setup qw( fake_installation );

use Test::More;
use Test::Output;
# }}}

use Reksio::Cmd::DelBuild;

plan tests =>
    + 1 # run with no params
    + 1 # check --help
    + 1 # check --version
    + 2 # del a build
    + 2 # del a nonexisting build
    + 2 # del from nonexisting repo
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $r1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');
my $r2_id = add_repository(name => 'Secnd', vcs=>'GIT', uri=>'git://lol/rotfl');
my $b1_id = add_build(
    repository_id => $r1_id,

    name          => 'Integrate',
    build_command => 'prove',

    frequency   => 'EACH',
    result_type => 'NONE'
);
my $b2_id = add_build(
    repository_id => $r1_id,

    name          => 'Cover',
    build_command => 'prove_cover',

    frequency   => 'RECENT',
    result_type => 'NONE'
);

my $exit_code;

stdout_like {
    $exit_code = Reksio::Cmd::DelBuild::main(),
} qr{^Usage}s, q{run with no parameters};
stdout_like {
    $exit_code = Reksio::Cmd::DelBuild::main('--help'),
} qr{^Usage}s, q{run with --help};
stdout_like {
    $exit_code = Reksio::Cmd::DelBuild::main('--version'),
} qr{version}s, q{run with --version};



stdout_like {
    $exit_code = Reksio::Cmd::DelBuild::main('--repo=First', '--name=Integrate'),
} qr{Build deleted}s, q{delete - clean exit (1/2)};

is(
    $exit_code,
    0,
    q{delete - exit code (2/2)},
);



stderr_like {
    $exit_code = Reksio::Cmd::DelBuild::main('--repo=First', '--name=Integrate'),
} qr{Build .+? does not exist\.}s, q{deny - build not exists - clean exit (1/2)};

is(
    $exit_code,
    1,
    q{deny - build not exists - clean exit (2/2)},
);



stderr_like {
    $exit_code = Reksio::Cmd::DelBuild::main('--repo=Third', '--name=Integrate'),
} qr{Repository .+? does not exist\.}s, q{deny - repo not exists - clean exit (1/2)};

is(
    $exit_code,
    1,
    q{deny - repo not exists - clean exit (2/2)},
);

# vim: fdm=marker
