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

use Reksio::API::Data qw( add_repository get_last_revision );
use Reksio::Test::Setup qw( fake_installation fake_repository );

use Test::More;
use Test::Output;
# }}}

use Reksio::Cmd::Inspect;

plan tests =>
    + 1 # run with no params
    + 1 # check --help
    + 1 # check --version
    + 4 # inspect (twice)
    + 1 # verify, that DB data is OK.
    + 2 # displays error, if repo does not exist
;

my $basedir = fake_installation($Bin .q{/../../t_data/});
my $fake_repo_path = fake_repository($Bin);

my $r1_id = add_repository(name => 'First', vcs=>'GIT', uri=>$fake_repo_path);


my $exit_code;

stdout_like {
    $exit_code = Reksio::Cmd::Inspect::main(),
} qr{^Usage}s, q{run with no parameters};
stdout_like {
    $exit_code = Reksio::Cmd::Inspect::main('--help'),
} qr{^Usage}s, q{run with --help};
stdout_like {
    $exit_code = Reksio::Cmd::Inspect::main('--version'),
} qr{version}s, q{run with --version};


stdout_like {
    $exit_code = Reksio::Cmd::Inspect::main('--repo=First');
} qr{Added data about 5 revisions.}s, q{inspect - clean exit};
is($exit_code, 0, q{inspect - 5 found});

stdout_like {
    $exit_code = Reksio::Cmd::Inspect::main('--repo=First');
} qr{Added data about 0 revisions.}s, q{inspect again - clean exit};
is($exit_code, 0, q{inspect again - 0 found});

#use Data::Dumper; warn Dumper get_last_revision(repository_id => $r1_id);

# FIXME: verify ALL data, not just the last revision.
is_deeply(
    get_last_revision(repository_id => $r1_id),
    {
        'id' => '5',

        'repository_id' => $r1_id,
        
        'commit_id'        => '3b06d05a012e8b25354e4d60498f07ce36962fb1',
        'parent_commit_id' => '815a65c4202092bd9f43f08c4d0090721224c2a0',

        'status' => 'N',

        'commiter'  => 'Bartłomiej Syguła',
        'message'   => 'Third test "fixed" ;)',
        'timestamp' => '1297338432',
    },
    q{verify inserted data},
);



stderr_like {
    $exit_code = Reksio::Cmd::Inspect::main('--repo=Foo'),
} qr{does not exist}s, q{Can not inspected non-existing repo - clean exit};
is($exit_code, 1, q{Can not inspected non-existing repo - exit code});

# vim: fdm=marker
