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

use Carp::Assert::More qw( assert_defined );
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
            name => { type=>SCALAR, optional=>1 },
            id   => { type=>SCALAR, optional=>1 },
        },
    );

    assert_defined( ( $P{'name'} or $P{'id'} ), "One (and only one) is defined: name or id");
    assert_defined(  not ( $P{'name'} and $P{'id'} ), "Only one is defined: name or id");
    
    my $sth = Reksio::Core::DB::do_select(
        'reksio_Repository',
        [qw( id name vcs uri )],
        \%P,
    );
    my $repo = $sth->fetchrow_hashref();

    return $repo;
} # }}}

# TODO
#sub get_repositories { # {{{
#} # }}}

# TODO: What, if repo has builds?
sub delete_repository { # {{{
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR, optional=>1 },
            id   => { type=>SCALAR, optional=>1 },
        },
    );

    assert_defined( ( $P{'name'} or $P{'id'} ), "One (and only one) is defined: name or id");
    assert_defined(  not ( $P{'name'} and $P{'id'} ), "Only one is defined: name or id");

    Reksio::Core::DB::do_delete(
        'reksio_Repository',
        \%P,
    );

    return;
} # }}}





# TODO
#sub add_build { # {{{
#} # }}}

# TODO
#sub get_build { # {{{
#} # }}}

# TODO
#sub get_builds { # {{{
#} # }}}

# TODO
#sub delete_build { # {{{
#} # }}}





# TODO
#sub add_revision { # {{{
#} # }}}

# TODO
#sub get_revision { # {{{
#} # }}}

# TODO
#sub get_revisions { # {{{
#} # }}}

# TODO
#sub delete_revision { # {{{
#} # }}}





# TODO
#sub add_result { # {{{
#} # }}}

# TODO
#sub get_result { # {{{
#} # }}}

# TODO
#sub get_results { # {{{
#} # }}}

# TODO
#sub delete_result { # {{{
#} # }}}

# vim: fdm=marker
1;
