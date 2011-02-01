package Reksio::Cmd::DelBuild;
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

use Reksio::Cmd;
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{build},
            desc  => q{Build name (label).},
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );


    return 0;
} # }}}


# vim: fdm=marker
1;
