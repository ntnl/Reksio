package Reksio::Core::Config;
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

use Carp::Assert::More qw( assert_defined );
use YAML::Any qw( Load );
# }}}

my %configuration = ();

sub set_config_option { # {{{
    my ( $option, $value ) = @_;

    $configuration{$option} = $value;

    return $value;
} # }}}

sub find_config { # {{{
    my @choices = (
        $ENV{'REKSIO_CONFIG'},
        q{./.reksio.conf},
        $ENV{'USER'} . q{/.reksio.conf}, # FIXME: will fail sometimes (probably) due to ENV{USER} being undefined...
        q{/etc/reksio.conf},
    );

    foreach my $path (@choices) {
        if (-f $path) {
            return $path;
        }
    }

    return;
} # }}}

sub configure { # {{{
    if ($configuration{'configured'}) {
        return;
    }

    my $config_file_path = find_config();

    my $config_src = Load($config_file_path);

    assert_defined($config_src->{'workspace'}, 'workspace is defined');

    # Note:
    #   Options 'build_results' and 'db' are mandatory for server.
    #   Workers require only 

    return $configuration{'configured'} = 1;
} # }}}

# vim: fdm=marker
1;
