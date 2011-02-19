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

=pod

=encoding UTF-8

=head1 NAME

Reksio::VCS - Base class for VCS-support modules

=head1 SUPPORTED VCS

Currently supported list of Version Control Systems include:

=over

=item GIT

Note: Branch support has not been tested, and is not guarantee to work.

=back

In next versions support for the following VCS is planned: Subversion and tar-based archive directories.

=head1 METHODS

=over

=item new

Parameters: B<HASH>.

 uri => String
    # VCS resource locator.

Returns: B<OBJECT>;

Purpose:

Generic constructor.

Do not use directly, call it from the implementing class! Example:

 use Reksio::VCS::GIT;
 
 my $vcs_handler = Reksio::VCS::GIT->new(
    uri => q{git@github.com:ntnl/Reksio.git},
 );

=cut

sub new { # {{{
    my ( $class, %P ) = @_;

    assert_defined($P{'uri'}, 'URI is defined.');

    my $self = {
        uri => $P{'uri'},
    };

    bless $self, $class;

    return $self;
} # }}}

=item revisions

Parameters: B<ARRAY>.

Returns: B<ARRAYREF>.

Each ARRAYREF element is a HASHREF, that describes single revision, as bellow:

 {
    'commit_id' => '3b06d05a012e8b25354e4d60498f07ce36962fb1',
    'parent'    => '815a65c4202092bd9f43f08c4d0090721224c2a0',
    'timestamp' => 1297338432,
    'commiter'  => 'Bartłomiej Syguła',
    'message'   => 'Third test "fixed" ;)',
 }

Purpose:

Inspect remote repository and return list of revisions in it.

Optionally, can return only revisions committed after given revision ID.

=cut

sub revisions { # {{{
    my ( $self, $start_at ) = @_;

    return $self->vcs_revisions($start_at);
} # }}}

=item checkout

Parameters: B<ARRAY>.

 $sandbox_folder
    # Checkout to this directory. Must exist.
 
 $commit_id
    # Revision ID, to checkout.

Returns: B<Undef>.

Purpose:

Checkout given Revision into given directory.

Function will I<die> if it fails.

=cut

sub checkout { # {{{
    my ( $self, $sandbox_location, $commit_id) = @_;

    return $self->vcs_checkout($sandbox_location, $commit_id);
} # }}}

=item uri

Parameters: B<None>.

Returns: B<String>.

Purpose:

Return Repository URL. Intended for use in VCS classes.

=cut

sub uri { # {{{
    my ( $self ) = @_;

    return $self->{'uri'};
} # }}}

=back

=head1 DEVELOPING VCS HANDLERS

=head2 Basics

Every VCS handler module should be based on Reksio::VCS:

 use base 'Reksio::VCS';

=head2 Required methods.

Every VCS handler has to implement the following methods:

=head3 vcs_revisions

=head3 vcs_checkout

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
