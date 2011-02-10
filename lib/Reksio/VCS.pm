package Reksio::VCS;
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

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
# }}}

sub new { # {{{
    my ( $class, %P ) = @_;

    assert_defined($P{'uri'}, 'URI is defined.');

    my $self = {
        uri => $P{'uri'},
    };

    bless $self, $class;

    return $self;
} # }}}

sub revisions { # {{{
    my ( $self, $start_at ) = @_;

    return $self->vcs_revisions($start_at);
} # }}}

sub checkout { # {{{
    my ( $self, $sandbox_location, $commit_id) = @_;

    return $self->vcs_checkout($sandbox_location, $commit_id);
} # }}}

sub uri { # {{{
    my ( $self ) = @_;

    return $self->{'uri'};
} # }}}

# vim: fdm=marker
1;
