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
use Reksio::Test::Setup qw( fake_installation_with_data );

use File::Slurp qw( read_file );
use Test::More;
use Test::Output;
# }}}

use Reksio::Cmd::Report;

plan tests =>
    + 1 # check --help
    + 1 # check --version
    + 5 * 4 # report
    + 2 # non-existing result
;

my $basedir = fake_installation_with_data($Bin .q{/../../t_data/});

$ENV{'TEST_EMAIL'} = 1;

my $exit_code;



# --- Smoke tests

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--version');
} qr{version}s, q{Check: --version};



my $report_file;

# ---

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 1);
} qr{Report .+? complete}s, q{Report - first - clean exit};
is($exit_code, 0, q{Report - first - exit code});

my $fake_email = Reksio::Test::Email::get_debug_stack()->[0];
like($fake_email->{'Data'}, qr{This commit passed all tests.}, q{Report - first - email});

$report_file = read_file($basedir . q{/builds/1/1/build_1/1-report.txt});
like($report_file, qr{Committed}s, q{Report - was generated});

# ---

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 2);
} qr{Report .+? complete}s, q{Report - passed - clean exit};
is($exit_code, 0, q{Report - passed - exit code});

my $fake_email = Reksio::Test::Email::get_debug_stack()->[0];
like($fake_email->{'Data'}, qr{This commit passed all tests.}, q{Report - first - email});

$report_file = read_file($basedir . q{/builds/1/2/build_1/2-report.txt});
like($report_file, qr{Committed}s, q{Report - was generated});

# ---

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 3);
} qr{Report .+? complete}s, q{Report - failure - clean exit};
is($exit_code, 0, q{Report - failure - exit code});

my $fake_email = Reksio::Test::Email::get_debug_stack()->[0];
like($fake_email->{'Data'}, qr{Tests broken by this commit}, q{Report - failure - email});

$report_file = read_file($basedir . q{/builds/1/3/build_1/3-report.txt});
like($report_file, qr{Committed}s, q{Report - was generated});

# ---

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 4);
} qr{Report .+? complete}s, q{Report - still broken - clean exit};
is($exit_code, 0, q{Report - still broken - exit code});

my $fake_email = Reksio::Test::Email::get_debug_stack()->[0];
like($fake_email->{'Data'}, qr{Tests still broken}, q{Report - still broken - email});

$report_file = read_file($basedir . q{/builds/1/4/build_1/4-report.txt});
like($report_file, qr{Committed}s, q{Report - was generated});

# ---

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 5);
} qr{Report .+? complete}s, q{Report - fix - clean exit};
is($exit_code, 0, q{Report - fix - exit code});

my $fake_email = Reksio::Test::Email::get_debug_stack()->[0];
like($fake_email->{'Data'}, qr{Tests fixed by this commit}, q{Report - fix - email});

$report_file = read_file($basedir . q{/builds/1/5/build_1/5-report.txt});
like($report_file, qr{Committed}s, q{Report - was generated});



# --- Crash tests

stderr_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=123');
} qr{Result .+? does not exist}s, q{No such result - clean exit};
is($exit_code, 1, q{No such result - exit code});

# vim: fdm=marker
