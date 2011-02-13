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
    delete_revision

    schedule_build

    get_result
    get_results
    update_result
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

# TODO
#sub get_builds { # {{{
#} # }}}

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

# TODO
#sub get_revisions { # {{{
#} # }}}

# TODO
#sub delete_revision { # {{{
#} # }}}





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

sub get_result { # {{{
    my %P = validate(
        @_,
        {
            id => { type=>SCALAR, optional=>1 },
        },
    );

    my $sth = Reksio::Core::DB::do_select(
        'reksio_Result',
        [qw( id revision_id build_id build_status build_stage report_status date_queued date_start date_finish total_tests_count total_cases_count failed_tests_count failed_cases_count )],
        \%P,
    );
    my $rev = $sth->fetchrow_hashref();

    return $rev;
} # }}}

# TODO
#sub get_results { # {{{
#} # }}}

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

# TODO
#sub delete_result { # {{{
#} # }}}

# vim: fdm=marker
1;
