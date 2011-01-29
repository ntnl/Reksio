package Reksio::Test::Setup;
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
    fake_installation
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

=head1 PURPOSE

Set up (fake) environment for automated tests.

=cut

sub fake_installation { # {{{
    my ( $t_data_dir ) = @_;

    my $basedir = sprintf q{/tmp/reksio-unit-test-%d/}, $PID;

    mkdir $basedir;

    mkdir $basedir . q{workspace/};
    mkdir $basedir . q{builds/};
    mkdir $basedir . q{db/};

    # FIXME: do not use shell commands.
    system q{cp}, $t_data_dir . q{empty_db.sqlite}, $basedir . q{db/db.sqlite};

    Reksio::Core::Config::set_config_option('workspace',     $basedir . q{workspace/});
    Reksio::Core::Config::set_config_option('build_results', $basedir . q{builds/});

    Reksio::Core::Config::set_config_option('db', $basedir . q{db/db.sqlite});

    return $basedir;
} # }}}

# vim: fdm=marker
1;
