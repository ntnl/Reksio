package Reksio::Cmd::AddRepo;
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

use Reksio::API::Data qw( get_repository add_repository );
use Reksio::Cmd;
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{name},
            desc  => q{Repository name (label).},
            type  => q{s},

            required => 1,
        },
        {
            param => q{vcs},
            desc  => q{Version control system.},
            type  => q{s},

            required => 1,
        },
        {
            param => q{uri},
            desc  => q{Location of the repository.},
            type  => q{s},

            required => 1,
        }
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    my $existing_repo = get_repository(
        name => $options->{'name'}
    );
    if ($existing_repo) {
        print STDERR q{Error: Repository with name '} . $options->{'name'} . qq{' already exists.\n};

        return 1;
    }

    my $id = add_repository(
        name => $options->{'name'},
        vcs  => $options->{'vcs'},
        uri  => $options->{'uri'},
    );

    print "Repository added (ID: $id)\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
