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
;

is(
    Reksio::Core::Config::set_config_option('workspace', '/tmp/'),
    '/tmp/',
    'set_config_option'
);

# vim: fdm=marker
