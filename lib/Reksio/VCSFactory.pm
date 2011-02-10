package Reksio::VCSFactory;
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

sub make { # {{{
    my ( $vcs, $uri ) = @_;

    assert_defined($vcs, 'VCS is defined.');
    assert_defined($uri, 'URI is defined.');

    my $path = q{Reksio/VCS/} . $vcs .q{.pm};

    require $path;

    my $class = q{Reksio::VCS::} . $vcs;

    my $vcs_handler = $class->new(
        uri => $uri,
    );

    return $vcs_handler;
} # }}}

# vim: fdm=marker
1;
