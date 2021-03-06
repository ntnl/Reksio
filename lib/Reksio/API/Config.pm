package Reksio::API::Config;
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

use Reksio::Core::Config;

use English qw( -no_match_vars );
# }}}

our @EXPORT_OK = qw(
    get_config_option
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

=pod

=encoding UTF-8

=head1 NAME

Reksio Configuration API

=head1 SYNOPSIS

 use Reksio::API::Config qw( get_config_option );

=head1 FUNCTIONS

=over

=item get_config_option

Parameters: B<ARRAY>.

 $config_option
   # String.

Returns: B<String>.

Purpose:

Return value of specified config option. If necessarily, will find and load config file.

If an option was not set will return undef.

Example:

 my $workspace_directory = get_config_option('workspace');

=cut

sub get_config_option { # {{{
    return Reksio::Core::Config::get_config_option(@_);
} # }}}

=back

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
