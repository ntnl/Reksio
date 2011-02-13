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

use Reksio::Cmd::Build;

plan tests =>
    + 1 # check --help
    + 1 # check --version
    + 5 # build
    + 2 # non-existing result
;

my $basedir = fake_installation($Bin .q{/../../t_data/});
my $repo_path = fake_repository($Bin);

my $rep1_id = add_repository(name => 'First', vcs=>'GIT', uri=>$repo_path);
my $b1_id = add_build(
    repository_id => $rep1_id,

    name => 'Prove',

    test_command => 'prove t/',

    frequency        => 'EACH',
    test_result_type => 'TAP'
);
my $rev1_id = add_revision(
    repository_id => $rep1_id,

    commit_id        => q{815a65c4202092bd9f43f08c4d0090721224c2a0},
    parent_commit_id => q{dfab002bc60ce992d235c0c3ecbeaad92c5e703c},

    commiter  => 'Bartłomiej Syguła',
    message   => 'Exec rights in place.',
    timestamp => 1297338336,
);
my $res1_id = schedule_build(
    revision_id => $rev1_id,
    build_id    => $b1_id,
);

my $exit_code;



stdout_like {
    $exit_code = Reksio::Cmd::Build::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::Build::main('--version');
} qr{version}s, q{Check: --version};



#    $exit_code = Reksio::Cmd::Build::main('--result_id=' . $res1_id);

stdout_like {
    $exit_code = Reksio::Cmd::Build::main('--result_id=' . $res1_id);
} qr{Build .+? complete}s, q{Build - clean exit};
is($exit_code, 0, q{Build - exit code});

my $raw_log = read_file($basedir . q{/builds/1/1/build_1/1-log.txt});
like($raw_log, qr{Test Summary Report}, q{Build - log written});

my $raw_details = read_file($basedir . q{/builds/1/1/build_1/1-details.yaml});
like($raw_details, qr{t\/third_test\.t\:.+?Failed}s, q{Build - details written});

#warn $raw_details;

my $result = get_result(id=>$res1_id);
#use Data::Dumper; warn Dumper $result;
is_deeply(
    $result,
    {
        id => $res1_id,

        revision_id => $rev1_id,
        build_id    => $b1_id,

        build_status  => 'N',
        build_stage   => 'N',
        report_status => 'N',

        total_tests_count  => 3,
        total_cases_count  => 8,
        failed_tests_count => 1,
        failed_cases_count => 1,

        date_queued => 0,
        date_start  => 0,
        date_finish => 0,
    },
    q{Build - result updated}
);

stderr_like {
    $exit_code = Reksio::Cmd::Build::main('--result_id=123');
} qr{Result .+? does not exist}s, q{No such result - clean exit};
is($exit_code, 1, q{No such result - exit code});

# vim: fdm=marker
