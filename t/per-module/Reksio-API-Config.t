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

use Reksio::API::Config qw( get_config_option );

plan tests =>
    + 1 # get_config_option
;

my $basedir = fake_installation($Bin .q{/../../t_data/});

like(
    get_config_option('workspace'),
    qr{^/tmp/},
    q{get_config_option: seems to return something sane.}
);

# vim: fdm=marker
