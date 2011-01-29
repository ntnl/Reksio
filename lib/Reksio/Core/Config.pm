package Reksio::Core::Config;
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

my $VERSION = '0.1.0';

# }}}

my %configuration = ();

sub set_config_option { # {{{
    my ( $option, $value ) = @_;

    $configuration{$option} = $value;

    return $value;
} # }}}

# vim: fdm=marker
1;
