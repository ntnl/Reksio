package Reksio::Test::Email;
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

# }}}

sub new_fake_msg { # {{{
    my ( $class ) = @_;

    my $self = {};

    bless $self, $class;

    return $self;
} # }}}

my @debug_stack;

sub send { # {{{
    my ( $self, $msg ) = @_;

    push @debug_stack, $msg;

    return;
} # }}}

# vim: fdm=marker
1;
