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
    get_last_revision
    get_revisions
    delete_revision

    schedule_build

    get_result
    get_results
    delete_result
);

plan tests =>
    + 2 # add_repository
    + 4 # get_repository

    + 3 # add_build
    + 4 # get_build
    + 2 # delete_build

    + 1 # add_revision
    + 2 # get_revision
    + 1 # get_last_revision

    + 1 # schedule a build
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

################################################################################
#
#                       Repository level tests
#
################################################################################

my $r1_id = add_repository(name => 'First', vcs=>'CVS', uri=>'cvs://foo/bar');
is($r1_id, 1, q{add_repository (1/2)});

my $r2_id = add_repository(name => 'Second', vcs=>'GIT', uri=>'https://foo/bar.git');
is($r2_id, 2, q{add_repository (2/2)});

is(
    get_repository( id=>123 ),
    undef,
    q{get_repository - by id (ask for not existing one)}
);
is(
    get_repository( name=>'FooBarBaz' ),
    undef,
    q{get_repository - by name (ask for not existing one)}
);
is_deeply(
    get_repository( id=>$r1_id ),
    {
        id   => $r1_id,
        name => 'First',
        vcs  => 'CVS',
        uri  => 'cvs://foo/bar'
    },
    q{get_repository - by id (ask for existing one)}
);
is_deeply(
    get_repository( name=>'Second' ),
    {
        id   => $r2_id,
        name => 'Second',
        vcs  => 'GIT',
        uri  => 'https://foo/bar.git',
    },
    q{get_repository - by name (ask for existing one)}
);

################################################################################
#
#                       Build level tests
#
################################################################################

my $b1_id = add_build(
    repository_id => $r1_id,

    name          => 'Integrate',
    build_command => 'prove',

    frequency   => 'EACH',
    result_type => 'NONE'
);
is ($b1_id, 1, q{add_build (1/3)});

my $b2_id = add_build(
    repository_id => $r1_id,

    name          => q{Coverage test},
    build_command => q{prove_cover},

    frequency   => 'RECENT',
    result_type => 'EXITCODE'
);
is ($b2_id, 2, q{add_build (2/3)});

my $b3_id = add_build(
    repository_id => $r2_id,

    name          => q{Run tests},
    build_command => q{./t/run_tests.sh},

    frequency   => 'DAILY',
    result_type => 'POD'
);
is ($b3_id, 3, q{add_build (3/3)});

is(
    get_build(id=>1234),
    undef,
    q{get_build - by ID - nonexisting build}
);
is_deeply(
    get_build(id=>$b2_id),
    {
        id            => $b2_id,
        repository_id => $r1_id,

        name          => q{Coverage test},
        build_command => q{prove_cover},

        frequency   => 'RECENT',
        result_type => 'EXITCODE',
    },
    q{get_build - by ID - existing build}
);

is(
    get_build(repository_id => 123, name => q{Foo}),
    undef,
    q{get_build - by name - nonexisting build}
);
is_deeply(
    get_build(repository_id => $r2_id, name => q{Run tests}),
    {
        id            => $b3_id,
        repository_id => $r2_id,

        name          => q{Run tests},
        build_command => q{./t/run_tests.sh},

        frequency   => 'DAILY',
        result_type => 'POD',
    },
    q{get_build - by name - existing build}
);

is(
    delete_build(id => $b1_id),
    undef,
    'delete_build - returns undef'
);
is(
    get_build(id => $b1_id),
    undef,
    q{delete_build - really deletes}
);


################################################################################
#
#                           Revision level tests
#
################################################################################

my $rev;

my $rev1_id = add_revision(
    repository_id => $r1_id,

    commit_id        => q{r0001},
    parent_commit_id => undef,

    commiter  => 'Bartłomiej Syguła',
    message   => 'First test',
    timestamp => '1297338154',
);
is($rev1_id, 1, 'add_revision');

$rev = get_revision( id=>$rev1_id );
is_deeply(
    $rev,
    {
        id => $rev1_id,

        repository_id => $r1_id,

        commit_id        => q{r0001},
        parent_commit_id => undef,

        commiter  => 'Bartłomiej Syguła',
        message   => 'First test',
        timestamp => '1297338154',

        status => 'N',
    },
    'get_revision - by ID',
);

$rev = get_revision(repository_id => $r1_id, commit_id => q{r0001});
is_deeply(
    $rev,
    {
        id => $rev1_id,

        repository_id => $r1_id,

        commit_id        => q{r0001},
        parent_commit_id => undef,

        commiter  => 'Bartłomiej Syguła',
        message   => 'First test',
        timestamp => '1297338154',

        status => 'N',
    },
    'get_revision - by Commit ID',
);

my $rev2_id = add_revision(
    repository_id => $r1_id,

    commit_id        => q{r0002},
    parent_commit_id => q{r0001},

    timestamp => 1297338432,
    commiter  => 'Bartłomiej Syguła',
    message   => 'Third test "fixed" ;)',
);

$rev = get_last_revision(repository_id => $r1_id);
is_deeply(
    $rev,
    {
        id => $rev2_id,

        repository_id => $r1_id,

        commit_id        => q{r0002},
        parent_commit_id => q{r0001},

        timestamp => 1297338432,
        commiter  => 'Bartłomiej Syguła',
        message   => 'Third test "fixed" ;)',

        status => 'N',
    },
    q{get_last_revision},
);

################################################################################
#
#                           Result level tests
#
################################################################################

my $res1_id = schedule_build(
    revision_id => $rev1_id,
    build_id    => $b1_id,
);
is ($res1_id, 1, 'schedule_build');

# vim: fdm=marker
