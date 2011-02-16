package Reksio::Cmd::Dispatch;
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

use Reksio::API::Config qw( get_config_option );
use Reksio::API::Data qw( get_repository get_revision get_build get_result update_result );
use Reksio::Cmd;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{sindle},
            desc  => q{Do just a single round, then exit.},
            type  => q{},

            required => 0,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    print "Dispatch : started\n";

    # ...

    print "Dispatch : ended.\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
