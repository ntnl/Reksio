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

use Reksio::API::Data qw( add_repository add_build add_revision schedule_build get_result );
use Reksio::Test::Setup qw( fake_installation fake_repository );

use File::Slurp qw( read_file );
use Test::More;
use Test::Output;
# }}}

use Reksio::Cmd::Dispatch;

plan tests =>
    + 1 # check --help
    + 1 # check --version
    + 2 # dispatch (run)
;

# Prepare "fake" environment. % {{{
my $basedir = fake_installation($Bin .q{/../../t_data/});
my $fake_repo_path = fake_repository($Bin .q{/../../t_data/});

$ENV{'TEST_EMAIL'} = 1;

my $r1_id = add_repository(name => 'First', vcs=>'GIT', uri=>$fake_repo_path);
my $b1_id = add_build(
    repository_id => $r1_id,

    name => 'Prove',

    test_command => 'prove t/',

    frequency        => 'EACH',
    test_result_type => 'TAP'
);
# }}}

my $exit_code;

# --- Smoke tests

stdout_like {
    $exit_code = Reksio::Cmd::Dispatch::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::Dispatch::main('--version');
} qr{version}s, q{Check: --version};


# --- Check functionality

#warn Reksio::Cmd::Dispatch::main('--single');
#system q{tree}, $basedir;

stdout_like {
    $exit_code = Reksio::Cmd::Dispatch::main('--single');
} qr{Dispatch : ended}, q{Dispatch - was run};
is($exit_code, 0, q{Dispatch - clean exit code});

#  Add more checks here...!

# vim: fdm=marker
