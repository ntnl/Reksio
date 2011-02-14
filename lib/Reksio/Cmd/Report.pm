package Reksio::Cmd::Report;
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
use Reksio::API::Data qw( get_repository get_revision get_build get_result update_result get_last_result );
use Reksio::Cmd;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file write_file );
use Params::Validate qw( :all );
use YAML::Any qw( LoadFile );
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{result_id},
            desc  => q{Result ID to report about.},
            type  => q{i},

            required => 1,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );
    
    # Check if the result exists.
    my $result_B = get_result(
        id => $options->{'result_id'}
    );
    if (not $result_B) {
        print STDERR q{Error: Result with ID '} . $options->{'result_id'} . qq{' does not exists.\n};

        return 1;
    }

    # Result will point Us to build, revision and repository.
    # We need their data to handle the Build process.
    my $build = get_build(
        id => $result_B->{'build_id'},
    );

    my $repo = get_repository(
        id => $build->{'repository_id'}
    );

    my $revision_B = get_revision(
        id => $result_B->{'revision_id'},
    );

    my $build_results_dir = get_config_option('build_results');
    assert_defined($build_results_dir);

    my $basedir_B = $build_results_dir . $repo->{'id'} .q{/}. $revision_B->{'id'} .q{/build_} . $build->{'id'} .q{/};
    my $details_B = LoadFile($basedir_B . $result_B->{'id'} .q{-details.yaml});

    my $report;
    my ( $revision_A, $result_A, $details_A );
    if ($revision_B->{'parent_commit_id'}) {
        $revision_A = get_revision(
            repository_id => $repo->{'id'},
            commit_id     => $revision_B->{'parent_commit_id'},
        );

        $result_A = get_last_result(
            build_id    => $build->{'id'},
            revision_id => $revision_A->{'id'},
        );

        my $basedir_A = $build_results_dir . $repo->{'id'} .q{/}. $revision_A->{'id'} .q{/build_} . $build->{'id'} .q{/};
        $details_A = LoadFile($basedir_A . $result_A->{'id'} .q{-details.yaml});

        $report = _compare_revisions($repo, $build, $revision_A, $details_A, $revision_B, $details_B);
    }
    else {
        $report = _describe_revision($repo, $build, $revision_B, $details_B);
    }
    
    print "Report for result ". $result_B->{'id'} ." complete.\n";

    return 0;
} # }}}

sub _separator { # {{{
    my ( $title ) = @_;

    my $string = qq{\n ---= } . $title . q{=};
    $string .= q{-} x ( 64 - length $title);
    $string .= qq{ - - -\n\n};

    return $string;
} # }}}

sub _format_test_file_line { # {{{
    my %P = validate(
        @_,
        {
            test    => { type=>SCALAR },
            details => { type=>HASHREF },
        }
    );

    my $string;
    if ($P{'details'}->{'status'} eq 'Fixed') {
        $string = sprintf q{  %45s %8s}, $P{'test'}, $P{'details'}->{'status'};
    }
    else {
        $string = sprintf q{  %45s %8s (%d of %d)}, $P{'test'}, $P{'details'}->{'status'}, $P{'details'}->{'failed_count'}, $P{'details'}->{'cases_count'};
    }

    return $string . qq{\n};
} # }}}

sub _compare_revisions { # {{{
    my ($repo, $build, $revision_A, $details_A, $revision_B, $details_B) = @_;

    my $report_text = _rep_describe_revision($revision_B);

    $report_text .= _separator('Tests change report');

    return $report_text;
} # }}}

sub _describe_revision { # {{{
    my ($repo, $build, $revision, $details) = @_;

    my $report_text = _rep_describe_revision($revision);

    $report_text .= _separator('Tests report');

    foreach my $test (keys %{ $details->{'tests'} }) {
        $report_text .= _format_test_file_line(
            test    => $test,
            details => $details->{'tests'}->{$test},
        );
    }

    return $report_text;
} # }}}

sub _rep_describe_revision { # {{{
    my ( $revision ) = @_;

    my $text = q{};

    $text .= q{Committed by } . $revision->{'commiter'} . q{ at } . ( localtime $revision->{'timestamp'} ) . qq{\n};
    $text .= qq{with message:\n} . $revision->{'message'} . qq{\n};
    $text .= qq{\n};

    # TODO: have list of changed files here.

    return $text;
} # }}}

# vim: fdm=marker
1;
