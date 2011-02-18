package Reksio::API::User;
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
use base 'Exporter';

my $VERSION = '0.1.0';

use Reksio::API::Config qw( get_config_option );

use English qw( -no_match_vars );
use YAML::Any qw( LoadFile );
# }}}

our @EXPORT_OK = qw(
    get_user_by_name
    get_user_by_vcs_id
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

=pod

=encoding UTF-8

=head1 NAME

Reksio User API

=head1 SYNOPSIS

 use Reksio::API::User qw( get_user_by_name get_user_by_vcs_id );

=head1 FUNCTIONS

=over

=item get_user_by_name

Parameters: B<ARRAY>.

 $name
    # User name.

=cut

sub get_user_by_name { # {{{
    my ( $name ) = @_;

    my $users_file_path = get_config_option('users_file');

    my $users_file = LoadFile($users_file_path);

    if ($users_file->{$name}) {
        return {
            %{ ( $users_file->{$name} or q{} ) },

            id => $name
        };
    }

    return;
} # }}}

=item get_user_by_vcs_id

Parameters: B<ARRAY>.

 $vcs_id
    # User VCS ID.

=cut

sub get_user_by_vcs_id { # {{{
    my ( $vcs_id ) = @_;

    my $users_file_path = get_config_option('users_file');

    my $users_file = LoadFile($users_file_path);

    foreach my $name (keys %{ $users_file }) {
        my $user = $users_file->{$name};

        foreach my $user_vcs_id (@{ $user->{'vcs_ids'} }) {
            if ($user_vcs_id eq $vcs_id) {
                return {
                    %{ ( $users_file->{$name} or q{} ) },

                    id => $name
                };
            }
        }
    }

    return;
} # }}}

=back

=head1 FIXME

This module screens REFACTOR ME!
But, since the whole sub-system is a temporal prosthetic, I do not care for at least a month from now...

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
