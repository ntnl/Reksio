package Reksio::Core::DB;
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

use Reksio::API::Config qw( get_config_option );

use Carp::Assert::More qw( assert_defined );
use DBI;
use English qw( -no_match_vars );
use SQL::Abstract;
# }}}

my $dbh;
my $abstract;

sub get_dbh { # {{{
    if ($dbh) {
        return $dbh;
    }

    my $db_config_string = get_config_option('db');

    assert_defined($db_config_string, 'DB configuration option is set.');

    my $options = {
        AutoCommit => 1,
        PrintError => 1
    };

    assert_defined($db_config_string, "Database configured.");

    if ($db_config_string =~ m{^sqlite:(.+?)$}s ) {
        my $filename = $1;

        $dbh = DBI->connect(q{dbi:SQLite:dbname=}. $filename, q{}, q{}, $options);
    }

    assert_defined($dbh, "Have DB connection.");

    # Prepare the SQL::Abstract object as well, for later use :)
    $abstract = SQL::Abstract->new();

    return $dbh;
} # }}}

# Notes:
#   $stuff - can be a hashref, or arrayref.
sub do_insert { # {{{
    my ($table, $stuff) = @_;

    my $_dbh = get_dbh();

    my($stmt, @bind) = $abstract->insert($table, $stuff);
    $_dbh->do($stmt, {}, @bind);

    return $_dbh->last_insert_id(undef, undef, undef, undef);
} # }}}

sub do_select { # {{{
    my ($table, $columns, $where, $order) = @_;

    my $_dbh = get_dbh();

    my($stmt, @bind) = $abstract->select($table, $columns, $where, $order);

    my $sth = $_dbh->prepare($stmt);
    $sth->execute(@bind);

    return $sth;
} # }}}

sub do_delete { # {{{
    my ($table, $where) = @_;

    my $_dbh = get_dbh();

    my($stmt, @bind) = $abstract->delete($table, $where);

    my $sth = $_dbh->prepare($stmt);
    $sth->execute(@bind);

    return;
} # }}}



sub prepare_and_execute { # {{{
    my ($stmt, $params) = @_;

    my $_dbh = get_dbh();

    my $sth = $_dbh->prepare($stmt);
    $sth->execute(@{ $params });

    return $sth;
} # }}}

# vim: fdm=marker
1;
