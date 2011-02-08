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

use Reksio::Cmd::AddBuild;

plan tests =>
    + 1 # run with no params
    + 1 # check --help
    + 1 # check --version
    + 6 # add builds
    + 2 # adding build to non-existing repo is not possible
    + 2 # adding second build with existing name is not possible
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $r1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');
my $r2_id = add_repository(name => 'Secnd', vcs=>'GIT', uri=>'git://lol/rotfl');

my $exit_code;

stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main(),
} qr{^Usage}s, q{run with no parameters};
stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--help'),
} qr{^Usage}s, q{run with --help};
stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--version'),
} qr{version}s, q{run with --version};



stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--repo=First', '--name=Tst1', '--build_command=prove', '--frequency=EACH', '--result_type=POD');
} qr{Build added}s, q{add - clean exit (1/3)};
is($exit_code, 0, q{add - exit code (1/3)});

stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--repo=First', '--name=Tst2', '--build_command=prove_cover', '--frequency=DAILY', '--result_type=EXITCODE');
} qr{Build added}s, q{add - clean exit (2/3)};
is($exit_code, 0, q{add - exit code (2/3)});

stdout_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--repo=Secnd', '--name=Tst1', '--build_command=prove', '--frequency=EACH', '--result_type=POD');
} qr{Build added}s, q{add - clean exit (3/3)};
is($exit_code, 0, q{add - exit code (3/3)});



stderr_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--repo=Foo', '--name=Tst1', '--build_command=prove', '--frequency=EACH', '--result_type=POD'),
} qr{does not exist}s, q{Can not duplicate name - clean exit};
is($exit_code, 1, q{Can not duplicate name - exit code});



stderr_like {
    $exit_code = Reksio::Cmd::AddBuild::main('--repo=Secnd', '--name=Tst1', '--build_command=prove', '--frequency=EACH', '--result_type=POD'),
} qr{already exist}s, q{Can not duplicate name - clean exit};
is($exit_code, 1, q{Can not duplicate name - exit code});

# vim: fdm=marker
