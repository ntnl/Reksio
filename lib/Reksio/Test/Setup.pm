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
# }}}

our @EXPORT_OK = qw(
    fake_installation
    fake_installation_with_data
    fake_repository
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

=head1 PURPOSE

Set up (fake) environment for automated tests.

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

    Reksio::Core::Config::set_config_option('workspace',     $install_path . q{workspace/});
    Reksio::Core::Config::set_config_option('build_results', $install_path . q{builds/});

    Reksio::Core::Config::set_config_option('db', q{sqlite:}. $install_path . q{db/db.sqlite});
    
    Reksio::Core::Config::set_config_option('configured', 1);

    return $install_path;
} # }}}

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

sub fake_installation_with_data { # {{{
    my ( $t_data ) = @_;
    
    $install_path = q{/tmp/git_test_install_} . $PID . q{/};

    mkdir $install_path;
    system q{cd }. $install_path .q{ && tar xzf } . $t_data . q{/test_install.tgz};

    Reksio::Core::Config::set_config_option('workspace',     $install_path . q{workspace/});
    Reksio::Core::Config::set_config_option('build_results', $install_path . q{builds/});

    Reksio::Core::Config::set_config_option('db', q{sqlite:}. $install_path . q{db/db.sqlite});
    
    Reksio::Core::Config::set_config_option('configured', 1);

    return $install_path;
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
