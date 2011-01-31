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

use GetOpt::Long ;
# }}}

sub main { # {{{
    my ($param_config, @params) = @_;

    push @{ $param_config }, {
        param => 'version',
        desc  => 'Show version and exit.',

        margin => 1,
    };
    push @{ $param_config }, {
        param => 'help',
        desc  => 'Show (this) short usage summary, and exit.',
    };

    my %options;

    if ($options{'help'}) {
        print STDERR "Usage:\n";
        print STDERR "\t...\n";

        return;
    }
    if ($options{'version'}) {
        print STDERR "Version: $VERSION\n";

        return;
    }

    return \%options;
} # }}}

# vim: fdm=marker
1;
