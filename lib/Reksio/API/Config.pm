package Reksio::API::Config;
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
use base 'Exporter';

my $VERSION = '0.1.0';

use Reksio::Core::Config;

use English qw( -no_match_vars );
# }}}

our @EXPORT_OK = qw(
    get_config_option
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

sub get_config_option { # {{{
    return Reksio::Core::Config::get_config_option(@_);
} # }}}

# vim: fdm=marker
1;
