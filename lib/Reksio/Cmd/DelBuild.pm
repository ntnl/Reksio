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

use Reksio::API::Data qw( get_repository get_build delete_build );
use Reksio::Cmd;
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{name},
            desc  => q{Build name (label).},
            type  => q{s},

            required => 1,
        },
        {
            param => q{repo},
            desc  => q{Repository name (label).},
            type  => q{s},

            required => 1,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    my $existing_repo = get_repository(
        name => $options->{'repo'}
    );
    if (not $existing_repo) {
        print STDERR q{Error: Repository with name '} . $options->{'repo'} . qq{' does not exist.\n};

        return 1;
    }

    my $existing_build = get_build(
        repository_id => $existing_repo->{'id'},

        name => $options->{'name'}
    );
    if (not $existing_build) {
        print STDERR q{Error: Build with name '} . $options->{'name'} . qq{' does not exist.\n};

        return 1;
    }

    delete_build(
        repository_id => $existing_repo->{'id'},

        name => $options->{'name'}
    );
    
    print "Build deleted.\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
