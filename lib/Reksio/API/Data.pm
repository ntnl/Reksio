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
    get_last_revision
    get_revisions
    update_revision

    schedule_build

    get_result
    get_results
    get_last_result
    update_result
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

=item add_repository

Parameters: B<HASH>.

 name => String
    # Repository name.
    # Name must be unique, server-wide, as it is used to identify the repository.
 
 vcs  => String
    # Codename of VCS type.
    # See Reksio::VCS for list of supported VCS types.
 
 uri  => String
    # URL format depends on the VCS used, see Reksio::VCS.

Returns: B<Integer> (Repository ID).

Purpose:

Create Repository entity.

=cut

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

=item get_repository

Parameters: B<HASH>.

 name => String
 
 id   => Integer

Returns: B<HASHREF | Undef>.

Purpose:

Return one Repository entity.

Example:

 my $repository = get_repository( id=>123 );
 
 my $repository = get_repository( name=>'Foo' );

=cut

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

=item get_repositories

Parameters: B<none>.

Returns: B<ARRAYREF>.

Purpose:

Return all Repository entries.

=cut

sub get_repositories { # {{{
    my $sth = Reksio::Core::DB::do_select(
        'reksio_Repository',
        [qw( id name vcs uri )],
    );

    my @repos;
    while (my $repo = $sth->fetchrow_hashref()) {
        push @repos, $repo;
    }

    return \@repos;
} # }}}

=item delete_repository

Parameters: B<HASH>.

 name => String
 
 id   => Integer

Returns: B<Undef>.

Purpose:

Delete a Repository entity.

Repository must not have any Builds or Revisions (delete them first).

=cut

# FIXME: What, if repo has builds?
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





=item add_build

Parameters: B<HASH>.

Returns: B<Integer> (Build ID).

Purpose:

Create Build entity in specified Repository.

=cut

sub add_build { # {{{
    my %P = validate(
        @_,
        {
            repository_id => { type=>SCALAR },
            name          => { type=>SCALAR },

            config_command => { type=>SCALAR, optional=>1 },
            build_command  => { type=>SCALAR, optional=>1 },
            test_command   => { type=>SCALAR, optional=>1 },

            frequency        => { type=>SCALAR },
            test_result_type => { type=>SCALAR },
        },
    );

    return Reksio::Core::DB::do_insert(
        'reksio_Build',
        {
            name          => $P{'name'},
            repository_id => $P{'repository_id'},

            config_command => $P{'config_command'},
            build_command  => $P{'build_command'},
            test_command   => $P{'test_command'},

            frequency        => $P{'frequency'},
            test_result_type => $P{'test_result_type'},
        }
    );
} # }}}

=item get_build

Parameters: B<HASH>.

 id => Integer
    # Build ID

 name => String
    # Repository name
 
 repository_id => Integer

Returns: B<HASHREF | Undef>.

Purpose:

Return one Build entity.

=cut

sub get_build { # {{{
    my %P = validate(
        @_,
        {
            name          => { type=>SCALAR, optional=>1 },
            repository_id => { type=>SCALAR, optional=>1 },
            id            => { type=>SCALAR, optional=>1 },
        },
    );

    assert_defined( ( ( $P{'name'} and $P{'repository_id'} ) or $P{'id'} ),   "One (and only one) is defined: name+repo or id");
    assert_defined(  not ( $P{'name'} and $P{'repository_id'} and $P{'id'} ), "Only one is defined: name+repo or id");
    
    my $sth = Reksio::Core::DB::do_select(
        'reksio_Build',
        [qw( id name repository_id config_command build_command test_command frequency test_result_type )],
        \%P,
    );
    my $repo = $sth->fetchrow_hashref();

    return $repo;
} # }}}

=item get_builds

Parameters: B<HASH>.

 id => Integer | ARRAYREF of Integers
    # Optional

 name => String | ARRAYREF of Strings
    # Optional
 
 repository_id => Integer | ARRAYREF of Integers
    # Optional

Returns: B<ARRAYREF>.

Purpose:

Return list of Builds matching given criteria.

=cut

sub get_builds { # {{{
    my %P = validate(
        @_,
        {
            name          => { type=>SCALAR | ARRAYREF, optional=>1 },
            repository_id => { type=>SCALAR | ARRAYREF, optional=>1 },
            id            => { type=>SCALAR | ARRAYREF, optional=>1 },
        },
    );
    
    # FIXME: check if any parameter was passed.

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Build',
        [qw( id name repository_id config_command build_command test_command frequency test_result_type )],
        \%P,
    );

    my @builds;
    while (my $build = $sth->fetchrow_hashref()) {
        push @builds, $build;
    }

    return \@builds;
} # }}}

=item delete_build

Parameters: B<HASH>.

 id => Integer
    # Build ID

 name => String
    # Build name
 
 repository_id => Integer
 
Returns: B<Undef>.

Purpose:

Delete a Build entity.

Build may not have any Results (delete them first).

=cut

sub delete_build { # {{{
    my %P = validate(
        @_,
        {
            name          => { type=>SCALAR, optional=>1 },
            repository_id => { type=>SCALAR, optional=>1 },
            id            => { type=>SCALAR, optional=>1 },
        },
    );

    assert_defined( ( ( $P{'name'} and $P{'repository_id'} ) or $P{'id'} ),   "One (and only one) is defined: name+repo or id");
    assert_defined(  not ( $P{'name'} and $P{'repository_id'} and $P{'id'} ), "Only one is defined: name+repo or id");

    my $sth = Reksio::Core::DB::do_delete(
        'reksio_Build',
        \%P,
    );

    return;
} # }}}



=item add_revision

Parameters: B<HASH>.

 repository_id => { type=>SCALAR },
 
 commit_id        => String
 
 parent_commit_id => String | Undef
 
 timestamp => Integer
    # Unit timestamp
 
 commiter => String
    # VCS User ID
 
 message => String
    # Commit message, as returned by VCS

Returns: B<Integer> (Revision ID).

Purpose:

Create Revision entry.

=cut

sub add_revision { # {{{
    my %P = validate(
        @_,
        {
            repository_id => { type=>SCALAR },

            commit_id        => { type=>SCALAR },
            parent_commit_id => { type=>SCALAR | UNDEF },

            timestamp => { type=>SCALAR },
            commiter  => { type=>SCALAR },
            message   => { type=>SCALAR, optional=>1 },
        },
    );

    return Reksio::Core::DB::do_insert(
        'reksio_Revision',
        {
            repository_id => $P{'repository_id'},

            repository_id => $P{'repository_id'},

            commit_id        => $P{'commit_id'},
            parent_commit_id => $P{'parent_commit_id'},

            commiter  => $P{'commiter'},
            message   => $P{'message'},
            timestamp => $P{'timestamp'},

            status => q{N},
        }
    );
} # }}}

=item get_revision

Parameters: B<HASH>.

 id => Integer
    # Revision ID
 
 repository_id => Integer
 
 commit_id => String

Returns: B<HASHREF | Undef>.

Purpose:

Return one Revision entity.

=cut

sub get_revision { # {{{
    my %P = validate(
        @_,
        {
            id            => { type=>SCALAR, optional=>1 },
            repository_id => { type=>SCALAR, optional=>1 },
            commit_id     => { type=>SCALAR, optional=>1 },
        },
    );

    assert_defined( ( $P{'id'} or ($P{'repository_id'} and $P{'commit_id'}) ), "One (and only one) is defined: id or repository_id+commit_id");
    assert_defined(  not ( $P{'id'} and ($P{'repository_id'} and $P{'commit_id'}) ), "Only one is defined: id or repository_id+commit_id");

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Revision',
        [qw( id repository_id commit_id parent_commit_id timestamp commiter message status )],
        \%P,
    );
    my $rev = $sth->fetchrow_hashref();

    return $rev;
} # }}}

=item get_last_revision

Parameters: B<HASH>.

 repository_id => Integer

Returns: B<HASHREF | Undef>.

Purpose:

Return most recent Revision from specified Repository.

=cut

sub get_last_revision { # {{{
    my %P = validate(
        @_,
        {
            repository_id => { type=>SCALAR },
        },
    );

    my $sth = Reksio::Core::DB::prepare_and_execute(
        q{SELECT * FROM reksio_Revision WHERE repository_id = ? ORDER BY timestamp DESC, id DESC LIMIT 1},
        [
            $P{'repository_id'},
        ],
    );

    my $rev = $sth->fetchrow_hashref();

    return $rev;
} # }}}

=item get_revisions

Parameters: B<HASH>.

 id => Integer | ARRAYREF of Integers,
    # Revision ID
 
 repository_id => Integer | ARRAYREF of Integers,
 
 commit_id => String | ARRAYREF of Strings
 
 status => Char | ARRAYREF or Chars
 
 commiter => String | ARRAYREF of Strings
    # VCS User ID

Returns: B<ARRAYREF>.

Purpose:

Return list of Revisions matching given criteria.

=cut

sub get_revisions { # {{{
    my %P = validate(
        @_,
        {
            id            => { type=>SCALAR | ARRAYREF, optional=>1 },
            repository_id => { type=>SCALAR | ARRAYREF, optional=>1 },
            commit_id     => { type=>SCALAR | ARRAYREF, optional=>1 },
            status        => { type=>SCALAR | ARRAYREF, optional=>1 },
            commiter      => { type=>SCALAR | ARRAYREF, optional=>1 },
        },
    );

    # FIXME: check if any parameter was passed.

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Revision',
        [qw( id repository_id commit_id parent_commit_id timestamp commiter message status )],
        \%P,
    );

    my @revisions;
    while (my $rev = $sth->fetchrow_hashref()) {
        push @revisions, $rev;
    }
    return \@revisions;
} # }}}

=item update_revision

Parameters: B<HASH>.

 id => Integer
    # Revision ID
    # This is the ID of Revision to update.
    # Other are values to set, and are optional (at least one has to be given).

 commit_id        => String
 parent_commit_id => String | Undef

 timestamp => Unit timestamp (Integer)
 commiter  => String
 message   => String
 
 status => { type=>SCALAR, optional=>1 },

Returns: B<Undef>.

Purpose:

Change one or more properties of Revision entity.

=cut

sub update_revision { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },

            commit_id        => { type=>SCALAR, optional=>1 },
            parent_commit_id => { type=>SCALAR | UNDEF, optional=>1 },

            timestamp => { type=>SCALAR, optional=>1 },
            commiter  => { type=>SCALAR, optional=>1 },
            message   => { type=>SCALAR, optional=>1 },
            
            status => { type=>SCALAR, optional=>1 },
        },
    );

    # FIXME: Check, if there was something else given, beside ID.

    my $revision_id = delete $P{'id'};

    return Reksio::Core::DB::do_update(
        'reksio_Revision',
        \%P,
        {
            id => $revision_id,
        }
    );
} # }}}





=item schedule_build

Parameters: B<HASH>.

 revision_id => Integer
 build_id    => Integer

Returns: B<Integer> (Result ID).

Purpose:

Creates a new Result entity, that is scheduled for processing by Build function.

=cut

sub schedule_build { # {{{
    my %P = validate(
        @_,
        {
            revision_id => { type=>SCALAR },
            build_id    => { type=>SCALAR },
        },
    );
    
    return Reksio::Core::DB::do_insert(
        'reksio_Result',
        {
            revision_id   => $P{'revision_id'},
            build_id      => $P{'build_id'},

            build_status  => 'N',
            build_stage   => 'N',
            report_status => 'N',

            date_queued => 0, # FIXME!
            date_start  => 0,
            date_finish => 0,

            total_tests_count  => 0,
            total_cases_count  => 0,
            failed_tests_count => 0,
            failed_cases_count => 0,
        }
    );
} # }}}

=item get_result

Parameters: B<HASH>.

 id => Integer
    # Result ID

Returns: B<HASHREF | Undef>.

Purpose:

Return one Result entity.

=cut

sub get_result { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },
        },
    );

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Result',
        [qw( id revision_id build_id build_status build_stage report_status date_queued date_start date_finish total_tests_count total_cases_count failed_tests_count failed_cases_count )],
        \%P,
    );
    my $result = $sth->fetchrow_hashref();

    return $result;
} # }}}

=item get_last_result

Parameters: B<HASH>.

 build_id    => Integer
 revision_id => Integer

Returns: B<HASHREF | Undef>.

Purpose:

Return most recent Build Result entity of given Revision.

Returns Undef, if no results of Build in given Revision exist.

Note, that this function can return Results that are scheduled, processed or complete Results.

=cut

# FIXME: cover this function in automated tests dedicated for this module.
sub get_last_result { # {{{
    my %P = validate(
        @_,
        {
            build_id    => { type=>SCALAR },
            revision_id => { type=>SCALAR },
        },
    );

    my $sth = Reksio::Core::DB::prepare_and_execute(
        q{SELECT * FROM reksio_Result WHERE revision_id = ? AND build_id = ? ORDER BY id DESC LIMIT 1},
        [
            $P{'revision_id'},
            $P{'build_id'},
        ],
    );

    my $rev = $sth->fetchrow_hashref();

    return $rev;
} # }}}

=item get_results

Parameters: B<HASH>.

 id => Integer
    # Result ID.

 revision_id => Integer
 build_id    => Integer

 build_status  => Char
 build_stage   => Char
 report_status => Char

Returns: B<ARRAYREF>.

Purpose:

Return list of Results matching given criteria.

=cut

sub get_results { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR | ARRAYREF, optional=>1 },

            revision_id => { type=>SCALAR | ARRAYREF, optional=>1 },
            build_id    => { type=>SCALAR | ARRAYREF, optional=>1 },

            build_status  => { type=>SCALAR | ARRAYREF, optional=>1 },
            build_stage   => { type=>SCALAR | ARRAYREF, optional=>1 },
            report_status => { type=>SCALAR | ARRAYREF, optional=>1 },
        },
    );

    # FIXME: Check, if at least one parameter was given.

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Result',
        [qw( id revision_id build_id build_status build_stage report_status date_queued date_start date_finish total_tests_count total_cases_count failed_tests_count failed_cases_count )],
        \%P,
    );
    my @results;
    while (my $result = $sth->fetchrow_hashref()) {
        push @results, $result;
    }

    return \@results;
} # }}}

=item update_result

Parameters: B<HASH>.

 id => Integer
    # This is the ID of Result to update.
    # Other are values to set, and are optional (at least one has to be given).
 
 build_status  => Char
 build_stage   => Char
 report_status => Char
 
 date_start  => (reserved)
 date_finish => (reserver)
 
 total_tests_count  => Integer
 total_cases_count  => Integer
 failed_tests_count => Integer
 failed_cases_count => Integer

Returns: B<Undef>.

Purpose:

Change one or more properties of Result entity.

=cut

sub update_result { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR },

            build_status  => { type=>SCALAR, optional=>1 },
            build_stage   => { type=>SCALAR, optional=>1 },
            report_status => { type=>SCALAR, optional=>1 },

            date_start  => { type=>SCALAR, optional=>1 },
            date_finish => { type=>SCALAR, optional=>1 },

            total_tests_count  => { type=>SCALAR | UNDEF, optional=>1 },
            total_cases_count  => { type=>SCALAR | UNDEF, optional=>1 },
            failed_tests_count => { type=>SCALAR | UNDEF, optional=>1 },
            failed_cases_count => { type=>SCALAR | UNDEF, optional=>1 },
        }
    );
    
    my $result_id = delete $P{'id'};

    # FIXME: check if there are any keys, after deleting the ID.

    Reksio::Core::DB::do_update(
        'reksio_Result',
        \%P,
        {
            id => $result_id
        }
    );

    return;
} # }}}

# vim: fdm=marker
1;
