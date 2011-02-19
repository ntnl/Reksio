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
use Test::More;
use YAML::Any qw( DumpFile );
# }}}

our @EXPORT_OK = qw(
    fake_installation
    fake_installation_with_data
    fake_repository
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

=pod

=encoding UTF-8

=head1 NAME

Reksio::Test::Setup - Reksio test environment setup.

=head1 PURPOSE

Set up (mock) different (fake) environments for use in automated tests.

=head1 DESCRIPTION

Installation directories are put in F</tmp> directory.
For best test performance, mount F</tmp> as I<tmpfs> (ramdisk).

=head1 FUNCTIONS

=over

=item fake_installation

Parameters: B<String> (t_data directory location).

Returns: B<String> (path to created installation).

=cut

my $install_path;

sub fake_installation { # {{{
    my ( $t_data_dir ) = @_;

    my $install_path = sprintf q{/tmp/reksio-unit-test-%d/}, $PID;

    mkdir $install_path;

    mkdir $install_path . q{workspace/};
    mkdir $install_path . q{builds/};
    mkdir $install_path . q{db/};

    # FIXME: do not use shell commands.
    system q{cp}, $t_data_dir . q{empty_db.sqlite}, $install_path . q{db/db.sqlite};

    DumpFile(
        $install_path . q{users.yaml},
        {
            "Bartłomiej Syguła" => {
                vcs_ids => [
                    "bs",
                    "bs502",
                    "bs5002",
                    "natanael",
                    "Bartłomiej Syguła",
                ],
                email => q{reksio-test@natanael.krakow.pl},
            },
            "FooBar" => {
                email => undef,
            },
        }
    );

    _write_fake_config($install_path);

    return $install_path;
} # }}}

=item fake_repository

Parameters: B<String> (t_data directory location).

Returns: B<String> (path to created repository).

Purpose:

Create a fake repository, that can be used in automated tests.

=cut

my $repo_path;

# Prepare the source test repository.
# (FIXME) the way it's done is lame. But, hey! Let's get it running first!
sub fake_repository { # {{{
    my ( $t_data ) = @_;

    $repo_path = q{/tmp/git_test_repo_} . $PID . q{/};
    mkdir $repo_path;
    system q{cd }. $repo_path .q{ && tar xzf } . $t_data . q{/test_repo.tgz};

    return $repo_path . q{test_repo/};
} # }}}

=item fake_installation_with_data

Parameters: B<String> (t_data directory location).

Returns: B<String> (path to created installation).

Purpose:

Create a fake installation, which already contains some test data.

=cut

sub fake_installation_with_data { # {{{
    my ( $t_data ) = @_;
    
    $install_path = q{/tmp/git_test_install_} . $PID . q{/};

    mkdir $install_path;
    system q{cd }. $install_path .q{ && tar xzf } . $t_data . q{/test_install.tgz};

    DumpFile(
        $install_path . q{users.yaml},
        {
            "Bartłomiej Syguła" => {
                vcs_ids => [
                    "bs",
                    "bs502",
                    "bs5002",
                    "natanael",
                    "Bartłomiej Syguła",
                ],
                email => q{reksio-test@natanael.krakow.pl},
            },
            "FooBar" => {
                email => undef,
            },
        }
    );

    _write_fake_config($install_path);

    return $install_path;
} # }}}

sub _write_fake_config { # {{{
    my ( $install_path ) = @_;

    my %config = (
        'workspace'     => $install_path . q{workspace/},
        'build_results' => $install_path . q{builds/},

        'db' => q{sqlite:}. $install_path . q{db/db.sqlite},
    
        'users_file', $install_path . q{users.yaml},
    );

    my $conf_path = $install_path . q{test.conf};

    DumpFile($conf_path, \%config);
    
    $ENV{'REKSIO_CONFIG'} = $conf_path;

    return;
} # }}}

END {
    if ($repo_path) {
        note("Cleaning test repo ($repo_path)");
        system q{rm}, q{-rf}, $repo_path;
    }

    if ($install_path) {
        note("Cleaning test install ($install_path)");
        system q{rm}, q{-rf}, $install_path;
    }
}

# vim: fdm=marker
1;
