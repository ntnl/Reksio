package Reksio::API::Data;
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

use Reksio::Core::DB;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_repository
    get_repository
    get_repositories
    delete_repository

    add_build
    get_build
    get_builds
    delete_build

    add_revision
    get_revision
    get_revisions
    delete_revision

    add_result
    get_result
    get_results
    delete_result
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);


sub add_repository { # {{{
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR },  # VARCHAR(128),
            vcs  => { type=>SCALAR },  # VARCHAR(32),
            uri  => { type=>SCALAR },  # VARCHAR(1024)
        },
    );
    
    return Reksio::Core::DB::do_insert(
        'reksio_Repository',
        {
            name => $P{'name'},
            vcs  => $P{'vcs'},
            uri  => $P{'uri'},
        }
    );
} # }}}

sub get_repository { # {{{
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR },  # VARCHAR(128),
            vcs  => { type=>SCALAR },  # VARCHAR(32),
            uri  => { type=>SCALAR },  # VARCHAR(1024)
        },
    );
} # }}}

sub get_repositories { # {{{
} # }}}

=stubs

sub delete_repository { # {{{
} # }}}





sub add_build { # {{{
} # }}}

sub get_build { # {{{
} # }}}

sub get_builds { # {{{
} # }}}

sub delete_build { # {{{
} # }}}





sub add_revision { # {{{
} # }}}

sub get_revision { # {{{
} # }}}

sub get_revisions { # {{{
} # }}}

sub delete_revision { # {{{
} # }}}





sub add_result { # {{{
} # }}}

sub get_result { # {{{
} # }}}

sub get_results { # {{{
} # }}}

sub delete_result { # {{{
} # }}}

=cut

# vim: fdm=marker
1;
