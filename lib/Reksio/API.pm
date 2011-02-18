package Reksio::API;
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
# }}}

=pod

=encoding UTF-8

=head1 NAME

Reksio - API reference.

=head1 DESCRIPTION

Reksio provides several APIs. Those can be used in third-party scripts/modules,
that want to inter-operate with Reksio.

All APIs are procedural and state-less, unless otherwise explicitly stated.

=head2 Configuration API

This module provides routines to access Reksio's configuration.

See: L<Reksio::API::Config>.

=head2 Data API

This module provides routines to access and manipulate Reksio's data.

See: L<Reksio::API::Data>;

=head2 User API

This module provides routines to access and manipulate User metadata.

See: L<Reksio::API::User>;

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
