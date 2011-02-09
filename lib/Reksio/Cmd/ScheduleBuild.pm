package Reksio::Cmd::ScheduleBuild;
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

use Reksio::API::Data qw( get_repository get_build get_revision schedule_build );
use Reksio::Cmd;
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{repo},
            desc  => q{Repository name (label).},
            type  => q{s},

            required => 1,
        },
        {
            param => q{build},
            desc  => q{Build name (label).},
            type  => q{s},

            required => 1,
        },
        {
            margin => 1,

            param => q{commit},
            desc  => q{Commit id.},
            type  => q{s},

            required => 1, # It could be optional!
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

        name => $options->{'build'}
    );
    if (not $existing_build) {
        print STDERR q{Error: Build with name '} . $options->{'build'} . qq{' does not exist.\n};

        return 1;
    }

    my $existing_rev = get_revision(
        repository_id => $existing_repo->{'id'},

        commit_id => $options->{'commit'},
    );
    if (not $existing_rev) {
        print STDERR q{Error: Commit with ID '} . $options->{'commit'} . qq{' does not exist in repository '}.$options->{'repo'}.qq{'.\n};

        return 1;
    }

    my $id = schedule_build(
        build_id    => $existing_build->{'id'},
        revision_id => $existing_rev->{'id'},
    );
    
    print "Build scheduled (ID: $id)\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
