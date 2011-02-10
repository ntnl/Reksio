package Reksio::VCS::GIT;
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
use base q{Reksio::VCS};

my $VERSION = '0.1.0';

use File::Slurp qw( read_file );
use English qw( -no_match_vars );
# }}}

sub vcs_revisions { # {{{
    my ($self, $start_at) = @_;

    my $lines = $self->_run(q{log}, $start_at .q{..HEAD});

    my %revisions;
    my $last_id;
    foreach my $line (@{ $lines }) {
        if ($line =~ m{commit ([^\s]+)}) {
            $last_id = $1;

            $revisions{$last_id} = {
                commit_id => $last_id,
            };

            next;
        }
    }

    return [ values %revisions ];
} # }}}

sub vcs_checkout { # {{{
    my ($self, $revision) = @_;

    return;
} # }}}

################################################################################
#                       Private methods.
################################################################################

sub _run { # {{{
    my ($self, @params) = @_;

    my $command = q{git} . join q{ }, map { q{'}.$_.q{'} } @params;

    my $pipe;
    open $pipe, q{-|}, $command;
    my @lines = read_file($pipe);
    close $pipe;

    return \@lines;
} # }}}

# vim: fdm=marker
1;
