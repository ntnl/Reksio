package Reksio::Cmd::AddBuild;
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
            param => q{name},
            desc  => q{Build name (label).},
        },
        {
            param => q{repo},
            desc  => q{Parent repository name (label).},
        },
        {
            param => q{frequency},
            desc  => q{How ofter to run the build (EACH, RECENT, HOURLY, DAILY).},
        },
        {
            param => q{build_command},
            desc  => q{Command executed to do the build},

            margin => 1,
        },
        {
            param => q{result_type},
            desc  => q{Expected output format (NONE, EXITCODE, POD).},
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );


    return 0;
} # }}}


# vim: fdm=marker
1;
