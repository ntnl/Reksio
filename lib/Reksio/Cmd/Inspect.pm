package Reksio::Cmd::Inspect;
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

use Reksio::API::Data qw( get_repository get_last_revision add_revision );
use Reksio::Cmd;
use Reksio::VCSFactory;
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
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    # Check if the repository exists.
    my $existing_repo = get_repository(
        name => $options->{'repo'}
    );
    if (not $existing_repo) {
        print STDERR q{Error: Repository with name '} . $options->{'repo'} . qq{' does not exists.\n};

        return 1;
    }

    my $vcs_handler = Reksio::VCSFactory::make($existing_repo->{'vcs'}, $existing_repo->{'uri'});

    my $last_known_revision = get_last_revision(
        repository_id => $existing_repo->{'id'},
    );

    my $revisions;
    if ($last_known_revision) {
        $revisions = $vcs_handler->revisions($last_known_revision->{'commit_id'}),
    }
    else {
        $revisions = $vcs_handler->revisions(),
    }

    my $count = 0;

    # FIXME: Sorting should be based on parent-commit relation!
    foreach my $revision (sort {$a->{'timestamp'} <=> $b->{'timestamp'}} @{ $revisions }) {
        add_revision(
            commit_id        => $revision->{'commit_id'},
            parent_commit_id => $revision->{'parent'},

            timestamp => $revision->{'timestamp'},
            commiter  => $revision->{'commiter'},
            message   => $revision->{'message'},
            
            repository_id => $existing_repo->{'id'},
        );

        $count++;
    }

    print "Added data about $count revisions.\n";

    return 0;
} # }}}

# vim: fdm=marker
1;
