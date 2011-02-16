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

use Carp::Assert::More qw( assert_defined );
# }}}

sub new_fake_msg { # {{{
    my ( $class, $msg ) = @_;

    assert_defined($msg);

    my $self = {
        msg=>$msg,
    };

    bless $self, $class;

    return $self;
} # }}}

my @debug_stack;

sub send { # {{{
    my ( $self ) = @_;

    push @debug_stack, $self->{'msg'};

    return;
} # }}}

sub get_debug_stack { # {{{
    my $stack = [ @debug_stack ];
    
    @debug_stack = ();

    return $stack;
} # }}}

# vim: fdm=marker
1;
