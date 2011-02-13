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

use Reksio::API::Data qw( add_repository add_build add_revision );
use Reksio::Test::Setup qw( fake_installation );

use Test::More;
use Test::Output;
# }}}

use Reksio::Cmd::ScheduleBuild;

plan tests =>
    + 1 # check --help
    + 1 # check --version
    + 2 * 2 # schedule a build
    + 2 # non-existing repo
    + 2 # non-existing build
    + 2 # non-existing commit
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

my $rep1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');
my $rep2_id = add_repository(name => 'Secnd', vcs=>'GIT', uri=>'git://lol/rotfl');

my $b1_id = add_build(
    repository_id => $rep1_id,

    name => q{Prove},

    test_command => q{./t/run_tests.sh},

    frequency        => 'DAILY',
    test_result_type => 'POD',    
);
my $b2_id = add_build(
    repository_id => $rep1_id,

    name => q{Coverage},

    test_command => q{./t/run_tests.sh},

    frequency        => q{RECENT},
    test_result_type => q{EXITCODE},
);

my $rev1_id = add_revision(
    repository_id => $rep1_id,

    commit_id        => q{r0001},
    parent_commit_id => undef,

    commiter  => 'Bartłomiej Syguła',
    message   => 'First test',
    timestamp => '1297338154',
);
my $rev2_id = add_revision(
    repository_id => $rep1_id,

    commit_id        => q{r0002},
    parent_commit_id => q{r0001},

    commiter  => 'Bartłomiej Syguła',
    message   => 'Second commit',
    timestamp => '1297347155',
);



my $exit_code;



stdout_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--version');
} qr{version}s, q{Check: --version};




stdout_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--repo=First', '--build=Prove', '--commit=r0001');
} qr{Build scheduled}s, q{Schedule - clean exit (1/2};
is($exit_code, 0, q{Schedule - exit code (1/2)});

stdout_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--repo=First', '--build=Coverage', '--commit=r0002');
} qr{Build scheduled}s, q{Schedule - clean exit (1/2};
is($exit_code, 0, q{Schedule - exit code (1/2)});



stderr_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--repo=Foo', '--build=Prove', '--commit=r0001');
} qr{Repository .+? does not exist}s, q{No such repo - clean exit};
is($exit_code, 1, q{No such repo - exit code});

stderr_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--repo=First', '--build=Builder', '--commit=r0001');
} qr{Build .+? does not exist}s, q{No such build - clean exit};
is($exit_code, 1, q{No such build - exit code});

stderr_like {
    $exit_code = Reksio::Cmd::ScheduleBuild::main('--repo=First', '--build=Prove', '--commit=5');
} qr{Commit with ID .+? does not exist}s, q{No such revision - clean exit};
is($exit_code, 1, q{No such revision - exit code});

# vim: fdm=marker
