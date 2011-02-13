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

use Reksio::API::Data qw( get_repository get_build add_build );
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
            desc  => q{Parent repository name (label).},
            type  => q{s},

            required => 1,
        },
        {
            param => q{config_command},
            desc  => q{Command executed to do the build},
            type  => q{s},

            margin => 1,
        },
        {
            param => q{build_command},
            desc  => q{Command executed to do the build},
            type  => q{s},
        },
        {
            param => q{test_command},
            desc  => q{Command executed to do the build},
            type  => q{s},
        },
        {
            param => q{frequency},
            desc  => q{How ofter to run the build (EACH, RECENT, HOURLY, DAILY).},
            type  => q{s},

            required => 1,

            margin => 1,
        },
        {
            param => q{test_result_type},
            desc  => q{Expected output format (NONE, EXITCODE, POD).},
            type  => q{s},

            required => 1,
        },
    );

    # TODO: check if at least one *_command was given.

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    # Check if the repository exists.
    my $existing_repo = get_repository(
        name => $options->{'repo'}
    );
    if (not $existing_repo) {
        print STDERR q{Error: Repository with name '} . $options->{'repo'} . qq{' does not exists.\n};

        return 1;
    }

    my $existing_build = get_build(
        repository_id => $existing_repo->{'id'},
        name          => $options->{'name'}
    );
    if ($existing_build) {
        print STDERR q{Error: Build with name '} . $options->{'name'} . q{' already exists in repository '} . $existing_repo->{'name'} . qq{'.\n};

        return 1;
    }

    my $id = add_build(
        repository_id => $existing_repo->{'id'},

        name      => $options->{'name'},
        frequency => $options->{'frequency'},

        config_command => $options->{'config_command'},
        build_command  => $options->{'build_command'},
        test_command   => $options->{'test_command'},

        test_result_type => $options->{'test_result_type'},
    );

    print "Build added (ID: $id)\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
