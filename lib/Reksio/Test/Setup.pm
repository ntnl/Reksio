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
    fake_repository
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

    Reksio::Core::Config::set_config_option('db', q{sqlite:}. $basedir . q{db/db.sqlite});
    
    Reksio::Core::Config::set_config_option('configured', 1);

    return $basedir;
} # }}}

my $repo_path;

# Prepare the source test repository.
# (FIXME) the way it's done is lame. But, hey! Let's get it running first!
sub fake_repository { # {{{
    my ( $bin ) = @_;

    $repo_path = q{/tmp/git_test_repo_} . $PID . q{/};
    mkdir $repo_path;
    chdir $repo_path;
    system q{tar}, q{xzf}, $bin .q{/../../t_data/test_repo.tgz};
    chdir $bin;

    return $repo_path . q{test_repo/};
} # }}}

END {
    if ($repo_path) {
        note("Cleaning test repo ($repo_path)");
        system q{rm}, q{-rf}, $repo_path;
    }
}

# vim: fdm=marker
1;
