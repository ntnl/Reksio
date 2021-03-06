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

use Reksio::Core::Config;

use Test::More;
# }}}

plan tests =>
    + 1 # set_config_option
    + 2 # configure
;

is(
    Reksio::Core::Config::set_config_option('workspace', '/tmp/'),
    '/tmp/',
    'set_config_option'
);

$ENV{'REKSIO_CONFIG'} = '/tmp/test.conf';

my $fh;
open $fh, q{>}, $ENV{'REKSIO_CONFIG'};
print $fh q{workspace: tmp};
close $fh;

is(
    Reksio::Core::Config::configure(),
    '/tmp/test.conf',
    'configure() found the config file'
);
is(
    Reksio::Core::Config::configure(),
    undef,
    'configure() will not re-configure'
);

# vim: fdm=marker
