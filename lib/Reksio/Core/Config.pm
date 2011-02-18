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
use YAML::Any qw( LoadFile );
# }}}

my %configuration = ();

sub set_config_option { # {{{
    my ( $option, $value ) = @_;

    $configuration{$option} = $value;

    return $value;
} # }}}

sub _find_config { # {{{
    my @choices = (
        $ENV{'REKSIO_CONFIG'},
        q{./.reksio.conf},
        q{/home/} . $ENV{'USER'} . q{/.reksio.conf}, # FIXME: do not guess, find out what the directory is (who said it always has to reside in /home?)
        q{/etc/reksio.conf},
    );

    my $config_path;
    foreach my $path (@choices) {
        if ($path and -f $path) {
            $config_path = $path;

            last;
        }
    }

    return $config_path;
} # }}}

sub configure { # {{{
    if ($configuration{'configured'}) {
        return;
    }

    my $config_file_path = _find_config();

    assert_defined($config_file_path, "Config file was found."); # FIXME: handle in more User-friendly name.
    
    %configuration = %{ LoadFile($config_file_path) };

    assert_defined($configuration{'workspace'}, 'workspace is defined');

    # Note:
    #   Options 'build_results' and 'db' are mandatory for server.
    #   Workers require only 

    $configuration{'configured'} = 1;

    return $config_file_path;
} # }}}

sub get_config_option { # {{{
    my ( $name ) = @_;

    assert_defined($name);

    configure();

    return $configuration{$name};
} # }}}

# vim: fdm=marker
1;
