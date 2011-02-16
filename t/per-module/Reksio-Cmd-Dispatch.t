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

use Reksio::Cmd::Dispatch;

plan tests =>
    + 1 # check --help
    + 1 # check --version
#    + 5 # dispatch
;

my $basedir = fake_installation_with_data($Bin .q{/../../t_data/});

my $exit_code;

# --- Smoke tests

stdout_like {
    $exit_code = Reksio::Cmd::Dispatch::main('--help');
} qr{Usage}s, q{Check: --help};

stdout_like {
    $exit_code = Reksio::Cmd::Dispatch::main('--version');
} qr{version}s, q{Check: --version};


# --- Check functionality



# vim: fdm=marker
