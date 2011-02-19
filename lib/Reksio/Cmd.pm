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

=pod

=encoding UTF-8

=head1 NAME

Reksio::Cmd - Reksio Command Line Interface

=head1 COMMANDS

Reksio provides a set of shell commands, that allow the server to be managed trough terminal (SSH) connection.

=head2 Repository management

=over

=item reksio_add_repository

=item reksio_drop_repository

=back

=head2 Build management

=over

=item reksio_add_build

=item reksio_drop_build

=item reksio_schedule_build

=back

=head2 Main scripts

=over

=item reksio_dispatch

=item reksio_inspect

=item reksio_build

=item reksio_report

=back

=head1 FUNCTIONS

=over

=item main

Parameters: B<ARRAY>.

Returns: B<Integer> (exit code).

Purpose:

Bootstrap Reksio command line interface scripts.

Usage:

 use Reksio::Cmd;
 
 exit Reksio::Cmd::main(@ARGV);

This function implements consistent command-line parameter parsing, support for I<--help> and I<--version>,
as well as some other details.

All Reksio commands should be based on this module/function for consistency.

=cut

sub main { # {{{
    my ($param_config, $argv_params) = @_;

    # By default, running with no parameters is allowed.
    # This is not true, if there is at least one required parameter.
    # In such situation, command should display help (instead is ranting about some missing parameters).
    my $require_parameters = 0;
    foreach my $param_def (@{ $param_config }) {
        if ($param_def->{'required'}) {
            $require_parameters = 1;
            last;
        }
    }

    if ($require_parameters and not scalar @{ $argv_params }) {
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

        my $cfg_string = $param_def->{'param'};
        if ($param_def->{'type'}) {
            $cfg_string .= q{=} . $param_def->{'type'};
        }

        $cfg{ $cfg_string } = \$options{ $param_def->{'param'} };
    }

    GetOptionsFromArray($argv_params, %cfg);

    if ($options{'help'}) {
        # Make sure, that the first option has a margin:
        $param_config->[0]->{'margin'} = 1;

        print "Usage:\n";
        print qq{\t} . $PROGRAM_NAME . qq{ [opts] [values]\n};

        foreach my $param_def (@{ $param_config }) {
            if ($param_def->{'margin'}) {
                print "\n";
            }

            printf qq{    --%s\t%s\n}, $param_def->{'param'}, $param_def->{'desc'};
        }

        return;
    }
    if ($options{'version'}) {
        print qq{$PROGRAM_NAME version: $VERSION\n};

        return;
    }
    
    foreach my $param_def (@{ $param_config }) {
        if ($param_def->{'required'} and not $options{ $param_def->{'param'} }) {
            print STDERR q{Command line parameter: '} . $param_def->{'param'} . qq{' was not found, but it is required.\n};

            return;
        }
    }

    return \%options;
} # }}}

=back

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
