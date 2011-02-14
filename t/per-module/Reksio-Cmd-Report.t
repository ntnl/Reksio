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
    + 10 # report
    + 2 # non-existing result
;

my $basedir = fake_installation_with_data($Bin .q{/../../t_data/});


my $exit_code;



stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--version');
} qr{version}s, q{Check: --version};



stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 1);
} qr{Report .+? complete}s, q{Report - first - clean exit};
is($exit_code, 0, q{Report - first - exit code});

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 2);
} qr{Report .+? complete}s, q{Report - passed - clean exit};
is($exit_code, 0, q{Report - passed - exit code});

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 3);
} qr{Report .+? complete}s, q{Report - failure - clean exit};
is($exit_code, 0, q{Report - failure - exit code});

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 4);
} qr{Report .+? complete}s, q{Report - still broken - clean exit};
is($exit_code, 0, q{Report - still broken - exit code});

stdout_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=' . 5);
} qr{Report .+? complete}s, q{Report - fix - clean exit};
is($exit_code, 0, q{Report - fix - exit code});



stderr_like {
    $exit_code = Reksio::Cmd::Report::main('--result_id=123');
} qr{Result .+? does not exist}s, q{No such result - clean exit};
is($exit_code, 1, q{No such result - exit code});

# vim: fdm=marker
