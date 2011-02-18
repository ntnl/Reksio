package Reksio::Cmd::Build;
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
use Reksio::API::Data qw( get_repository get_revision get_build get_result update_result );
use Reksio::Cmd;
use Reksio::VCSFactory;

use Carp::Assert::More qw( assert_defined );
use Digest::MD5 qw( md5_hex );
use English qw( -no_match_vars );
use File::Slurp qw( read_file write_file );
use YAML::Any qw( DumpFile );
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{result_id},
            desc  => q{Result ID to update.},
            type  => q{s},

            required => 1,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );
    
    # Check if the result exists.
    my $result = get_result(
        id => $options->{'result_id'}
    );
    if (not $result) {
        print STDERR q{Error: Result with ID '} . $options->{'result_id'} . qq{' does not exists.\n};

        return 1;
    }

    # Update result - mark as "Running"
    # TODO: get a lock on that Build (needed when commands will run in paralel)

    # ...

    # Result will point Us to build, revision and repository.
    # We need their data to handle the Build process.
    my $build = get_build(
        id => $result->{'build_id'},
    );

    my $revision = get_revision(
        id => $result->{'revision_id'},
    );

    my $repo = get_repository(
        id => $build->{'repository_id'}
    );

    # Checkout the exact commit, that We are to build.

    my $vcs_handler = Reksio::VCSFactory::make($repo->{'vcs'}, $repo->{'uri'});

    my $workspace = get_config_option('workspace');
    assert_defined($workspace);

    my $sandbox_location = sprintf q{%s/%s_%d}, $workspace, md5_hex($repo->{'uri'}), $PID;

    if (-d $sandbox_location) {
        # FIXME: ugly hack!
        system q{rm}, q{-rf}, $sandbox_location;
    }

    mkdir $sandbox_location;

    $vcs_handler->checkout($sandbox_location, $revision->{'commit_id'});

    # Run the build
    my $output;
    my %detailed_result;

    # Tests configured?
    if ($build->{'test_command'}) {
        my $pipe;
        if (not open $pipe, q{-|}, q{cd } . $sandbox_location .q{ && } . $build->{'test_command'} . q{ 2>&1}) {
            # FIXME: cover this use-case in automated tests!
            print STDERR q{Error: Test command failed.};

            # FIXME: emit some debug information.

            update_result(
                id => $result->{'id'},

                build_status => q{E}, # E = Internal Error
                build_stage  => q{D},
            );

            return 2;
        }

        $output .= read_file($pipe);
        my $close_status = close $pipe;

#        warn $output;

        my %result_update;
        if ($build->{'test_result_type'} eq q{EXITCODE}) {
            # Check exit code.
            # FIXME: cover this use-case in automated tests!
            if ($close_status and not $!) {
                # Not clean exit.
                $result_update{'build_status'} = q{N}; # Finish: Negative
            }
            else {
                # Clean exit.
                $result_update{'build_status'} = q{P}; # Finish: Positive
            }
        }
        elsif ($build->{'test_result_type'} eq q{TAP}) {
            # Analyze TAP output.
            my $tests = _analyze_tap_report($output);

            # This goes into DB...
            $result_update{'build_status'} = $tests->{'status'};
        
            $result_update{'total_tests_count'}  = $tests->{'total_tests_count'};
            $result_update{'total_cases_count'}  = $tests->{'total_cases_count'};
            $result_update{'failed_tests_count'} = $tests->{'failed_tests_count'};
            $result_update{'failed_cases_count'} = $tests->{'failed_cases_count'};

            # This goes into the file...
            $detailed_result{'tests'} = $tests->{'tests'};
        }
        else {
            # Build always successful.
            # FIXME: cover this use-case in automated tests!
            $result_update{'build_status'} = q{P}; # Finish: Positive
        }

        update_result(
            %result_update,

            build_stage => 'D',

            report_status => 'B', # FIXME: sometimes this should be 'W' (!!!), but this will matter when command will be run in parallel.

            id => $result->{'id'},
        );
    }

    # Write raw output to file.
    my $build_results_dir = get_config_option('build_results');
    assert_defined($build_results_dir);

    if (not -d $build_results_dir . $repo->{'id'}) {
        mkdir $build_results_dir . $repo->{'id'};
    }
    if (not -d $build_results_dir . $repo->{'id'} .q{/}. $revision->{'id'}) {
        mkdir $build_results_dir . $repo->{'id'} .q{/}. $revision->{'id'};
    }
    if (not -d $build_results_dir . $repo->{'id'} .q{/}. $revision->{'id'} .q{/build_} . $build->{'id'}) {
        mkdir $build_results_dir . $repo->{'id'} .q{/}. $revision->{'id'} .q{/build_} . $build->{'id'};
    }

    # Finish the build process.

    my $output_basedir = $build_results_dir . $repo->{'id'} .q{/}. $revision->{'id'} .q{/build_} . $build->{'id'} .q{/};

    write_file($output_basedir . $result->{'id'} .q{-log.txt}, $output);

    # TODO: At this point, if build is broken, We could archive the directory for post-mortem analysis.

    DumpFile($output_basedir . $result->{'id'} .q{-details.yaml}, \%detailed_result);
    
#    warn $sandbox_location; <>;

    # Remove build location, it's a temp directory.
    # FIXME: ugly hack!
    system q{rm}, q{-rf}, $sandbox_location;

#    warn $output_basedir . $result->{'id'} .q{-log.txt} . q{ written :)};

    print "Build for result ". $result->{'id'} ." complete.\n";

    return 0;
} # }}}

# Purpose:
#   Parse output of TAP::Harness, and return tests report.
sub _analyze_tap_report { # {{{
    my ( $tap_report ) = @_;

    my %report = (
        status => q{U},

        total_tests_count  => undef,
        total_cases_count  => undef,
        failed_tests_count => undef,
        failed_cases_count => undef,

        tests => {},
    );

    my @lines = split /\n/, $tap_report;

    my $i = 0;
    my $current_test;
    my $report_found;
    while (defined $lines[$i]) {
        my $line = $lines[$i];
        chomp $line;

        $i++;

        if (not $report_found) {
            if ($line =~ qr{Test Summary Report}) {
                $report_found = 1;
            
                next;
            }

            if ($line =~ qr{All tests successful\.}) {
                $report_found = 1;

                next;
            }

            next;
        }

        if ($line =~ m{^Files=(\d+), Tests=(\d+),}s) {
            my ( $files, $cases ) = ( $1, $2 );

            $report{'total_tests_count'} = $files;
            $report{'total_cases_count'} = $cases;

            next;
        }

        if ($line =~ m{^Result:\s(FAIL|PASS)}s) {
            my $result = $1;

            if ($result eq 'FAIL') {
                $report{'status'} = 'F';
        
                last;
            }

            if ($result eq 'PASS') {
                $report{'status'} = 'P';

                $report{'failed_tests_count'} = 0;
                $report{'failed_cases_count'} = 0;

                last;
            }
        }

        if ($line =~ qr{^([^\s]+)\s+\(Wstat: \d+ Tests: (\d+) Failed: (\d+)}s) {
            my ( $test, $t_count, $f_count ) = ( $1, $2, $3 );

            $current_test = $report{'tests'}->{$test} = {
                status => 'Failed',

                cases_count  => $t_count,
                failed_count => $f_count,
            };

            $report{'failed_tests_count'}++;
            
            $report{'failed_cases_count'} += $f_count;

            next;
        }

        if ($line =~ m{exit status: 255}s) {
            $current_test->{'status'} = 'Died';
            next;
        }

        if ($line =~ m{Failed tests:\s+(.+?)$}s) {
            my $broken_cases = $1;

            my @cases = _split_tap_cases($broken_cases);

            $current_test->{'failed_count'} = scalar @cases;

            next;
        }

#        warn "Unmatched line: $line";
    }

    return \%report
} # }}}

# TODO: In future, We will be able to track EXACTLY which cases ware broken.
sub _split_tap_cases { # {{{
    my ( $cases_string ) = @_;

#    warn $cases_string;

    my @strings = split qr{, }, $cases_string;

    my @cases;
    foreach my $string (@strings) {
        if ($string =~ m{(\d+)-(\d)}s) {
            my ( $from, $to ) = ( $1, $2 );
            
            foreach my $i ($from .. $to) {
                push @cases, $i;
            }
        }
        else {
            push @cases, int $string;
        }
    }

    return @cases;
} # }}}

# vim: fdm=marker
1;
