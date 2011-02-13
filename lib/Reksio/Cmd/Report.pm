package Reksio::Cmd::Report;
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
use File::Slurp qw( read_file write_file );
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{result_id},
            desc  => q{Result ID to report about.},
            type  => q{i},

            required => 1,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );
    
    # Check if the result exists.
    my $result = get_result(
        id => $options->{'result_id'}
    );
    if (not $result) {
        print STDERR q{Error: Result with ID '} . $options->{'result_id'} . qq{' does not exists.\n};

        return 1;
    }


    return 0;
} # }}}

# vim: fdm=marker
1;
