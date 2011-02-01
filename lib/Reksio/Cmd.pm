package Reksio::Cmd;
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

use English qw( -no_match_vars );
use Getopt::Long 2.36 qw( GetOptionsFromArray );
# }}}

sub main { # {{{
    my ($param_config, $argv_params) = @_;

    if (scalar @{ $param_config } and not scalar @{ $argv_params }) {
        $argv_params = [ '--help' ];
    }

    push @{ $param_config }, {
        param => 'version',
        desc  => 'Show version and exit.',

        margin => 1,
    };
    push @{ $param_config }, {
        param => 'help',
        desc  => 'Show (this) short usage summary, and exit.',
    };

    my %cfg;
    my %options;
    foreach my $param_def (@{ $param_config }) {
        $options{ $param_def->{'param'} } = q{};

        $cfg{ $param_def->{'param'} } = \$options{ $param_def->{'param'} };
    }

    GetOptionsFromArray($argv_params, %cfg);

    if ($options{'help'}) {
        # Make sure, that the first option has a margin:
        $param_config->[0]->{'margin'} = 1;

        print STDERR "Usage:\n";
        print STDERR qq{\t} . $PROGRAM_NAME . qq{ [opts] [values]\n};

        foreach my $param_def (@{ $param_config }) {
            if ($param_def->{'margin'}) {
                print STDERR "\n";
            }

            printf qq{    --%s\t%s\n}, $param_def->{'param'}, $param_def->{'desc'};
        }

        return;
    }
    if ($options{'version'}) {
        print STDERR qq{$PROGRAM_NAME version: $VERSION\n};

        return;
    }

    return \%options;
} # }}}

# vim: fdm=marker
1;