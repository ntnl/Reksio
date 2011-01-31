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
# }}}

my $dbh;

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

    if ($db_config_string =~ m{^sqlite:(.+?)$}s ) {
        my $filename = $1;

        $dbh = DBI->connect(q{dbi:SQLite:dbname=}. $filename, q{}, q{}, $options);
    }
    # FIXME: Notify the User, that He has not configured db properly :(

    return $dbh;
} # }}}

# vim: fdm=marker
1;
