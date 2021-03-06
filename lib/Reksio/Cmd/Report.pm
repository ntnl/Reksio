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
use Reksio::API::User qw( get_user_by_vcs_id );
use Reksio::Cmd;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file write_file );
use MIME::Lite;
use Params::Validate qw( :all );
use YAML::Any qw( DumpFile LoadFile );
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

    my $user = ( get_user_by_vcs_id($revision_B->{'commiter'}) or {} );

    my $build_results_dir = get_config_option('build_results');
    assert_defined($build_results_dir);

    my $basedir_B = $build_results_dir . $repo->{'id'} .q{/}. $revision_B->{'id'} .q{/build_} . $build->{'id'} .q{/};
    my $details_B = LoadFile($basedir_B . $result_B->{'id'} .q{-details.yaml});

    my ( $report, $title );
    my ( $revision_A, $result_A, $details_A );
    if ($revision_B->{'parent_commit_id'}) {
        $revision_A = get_revision(
            repository_id => $repo->{'id'},
            commit_id     => $revision_B->{'parent_commit_id'},
        );

        # What, if We find no revision? Such thing should not happen, right?

        $result_A = get_last_result(
            build_id    => $build->{'id'},
            revision_id => $revision_A->{'id'},
        );

        my $basedir_A = $build_results_dir . $repo->{'id'} .q{/}. $revision_A->{'id'} .q{/build_} . $build->{'id'} .q{/};
        $details_A = LoadFile($basedir_A . $result_A->{'id'} .q{-details.yaml});

        ( $report, $title ) = _compare_revisions($repo, $build, $revision_A, $details_A, $revision_B, $details_B);
    }
    else {
        ( $report, $title ) = _describe_revision($repo, $build, $revision_B, $details_B);
    }
    
#    warn $report;

    write_file($basedir_B . $result_B->{'id'} .q{-report.txt}, $report);

    # Send the report by email...

    if ($user->{'email'}) {
#        warn $user->{'email'};

        my $msg = MIME::Lite->new(
#            From    => 'me@myhost.com', # TODO
            To      => $user->{'email'},
#            Cc       =>'some@other.com, some@more.com', # TODO
            Subject => q{Reksio: } . $title,
            Data    => qq{\n} . $report,
        );

        if ($ENV{'TEST_EMAIL'}) {
            # FIXME: Note to self: current solution is not clean. Reimplement.
            # Fake the message object if running in test mode.
            require Reksio::Test::Email;
            $msg = Reksio::Test::Email->new_fake_msg($msg);
        }

        $msg->send();
    }

    print "Report for result ". $result_B->{'id'} ." complete.\n";

    return 0;
} # }}}

sub _separator { # {{{
    my ( $title ) = @_;

    my $string = qq{\n ---= } . $title . q{ =};
    $string .= q{-} x ( 48 - length $title);
    $string .= qq{ - - -\n\n};

    return $string;
} # }}}

sub _format_test_file_line { # {{{
    my %P = validate(
        @_,
        {
            test    => { type=>SCALAR },
            details => { type=>HASHREF },
            status  => { type=>SCALAR },
        }
    );

    # FIXME: if test name is bigger then 45 characters, make a "foo...bar" aut of it.

    my $string;
    if ($P{'details'}->{'failed_count'}) {
        $string = sprintf q{  %-45s %8s}, $P{'test'}, $P{'status'};
    }
    else {
        $string = sprintf q{  %-45s %8s (%d of %d)}, $P{'test'}, $P{'status'}, $P{'details'}->{'failed_count'}, $P{'details'}->{'cases_count'};
    }

    return $string . qq{\n};
} # }}}

sub _compare_revisions { # {{{
    my ($repo, $build, $revision_A, $details_A, $revision_B, $details_B) = @_;

    my $report_text = _rep_describe_revision($repo, $build, $revision_B);
    my $report_title;

    if (not scalar keys %{ $details_A->{'tests'} } and not scalar keys %{ $details_B->{'tests'} }) {
        $report_text .= _separator('All tests passed');

        $report_text .= "This commit passed all tests.";

        $report_title = _title('Pass', $repo, $build, $revision_B);
    }
    else {
        my %test_pool = (
            'Fixed'  => {
                label => "Tests fixed by this commit",
                tests => {},
            },
            'Broken' => {
                label => "Tests broken by this commit",
                tests => {},
            },
            'Failing' => {
                label => "Tests still broken",
                tests => {},
            },
        );

        foreach my $test (keys %{ $details_A->{'tests'} }) {
            if ($details_B->{'tests'}->{$test}) {
                # Broken in both revisions.
                $test_pool{'Failing'}->{'tests'}->{$test} = $details_B->{'tests'}->{$test}->{'status'};
            }
            else {
                # Broken in previous revision, but now it passed = fixed :)
                $test_pool{'Fixed'}->{'tests'}->{$test} = 'Passed';
            }
        }
        foreach my $test (keys %{ $details_B->{'tests'} }) {
            if (not $details_A->{'tests'}->{$test}) {
                $test_pool{'Broken'}->{'tests'}->{$test} = $details_B->{'tests'}->{$test}->{'status'};
            }
        }

        foreach my $section (qw( Fixed Broken Failing )) {
            my $count = scalar keys %{ $test_pool{$section}->{'tests'} };

            if (not $count) {
                # This section is empty. Skip it.
                next;
            }

            $report_text .= _separator($test_pool{$section}->{'label'} . q{ (}. $count .q{)});

            foreach my $test (keys %{ $test_pool{$section}->{'tests'} }) {
                $report_text .= _format_test_file_line(
                    test    => $test,
                    details => ( $details_B->{'tests'}->{$test} or $details_A->{'tests'}->{$test} ),
                    status  => $test_pool{$section}->{'tests'}->{$test}
                );
            }
        }

        my $title_status = q{Fail}; # Pessimistic by default ;)

        if (scalar keys %{ $test_pool{'Broken'}->{'tests'} }) {
            $title_status = q{FMore};
        }
        elsif (scalar keys %{ $test_pool{'Fixed'}->{'tests'} }) {
            if (scalar keys %{ $test_pool{'Failing'}->{'tests'} }) {
                $title_status = q{Fix};
            }
            else {
                $title_status = q{FLess};
            }
        }

        $report_title = _title($title_status, $repo, $build, $revision_B);
    }

    return ( $report_text, $report_title );
} # }}}

sub _describe_revision { # {{{
    my ($repo, $build, $revision, $details) = @_;

    my $report_text = _rep_describe_revision($repo, $build, $revision);
    my $report_title;

    if (not scalar keys %{ $details->{'tests'} }) {
        $report_text .= _separator('All tests passed');

        $report_text .= "This commit passed all tests.";

        $report_title = _title('Pass', $repo, $build, $revision);
    }
    else {
        $report_text .= _separator('Tests broken by this commit');

        foreach my $test (keys %{ $details->{'tests'} }) {
            $report_text .= _format_test_file_line(
                test    => $test,
                details => $details->{'tests'}->{$test},
                status  => $details->{'tests'}->{$test}->{'status'},
            );
        }

        $report_title = _title('Fail', $revision);
    }

    return ( $report_text, $report_title );
} # }}}

sub _title { # {{{
    my ( $status, $repository, $build, $revision ) = @_;
    
    assert_defined($repository);
    assert_defined($build);
    assert_defined($revision);

    my %text = (
        # Bad scenarios:
        'Fail'  => q{still failing},
        'FLess' => q{failed less},
        'FMore' => q{failed more},

        # Good scenarios:
        'Fix'  => q{fixed},
        'Pass' => q{passed cleanly},
    );

    return $build->{'name'} .q{ }. $text{$status} . q{ in } . $repository->{'name'} . q{ r: } . $revision->{'commit_id'};
} # }}}

sub _rep_describe_revision { # {{{
    my ( $repository, $build, $revision ) = @_;

    my $text = q{};
    
    my $message = $revision->{'message'};
    chomp $message;

    $text .= qq{Report for:\n};
    $text .= q{  Repository: }. $repository->{'name'}. qq{\n};
    $text .= q{       Build: }. $build->{'name'}. qq{\n};
    $text .= q{   Commit ID: }. $revision->{'commit_id'}. qq{\n};
    $text .= qq{\n};
    $text .= q{Committed by } . $revision->{'commiter'} . q{ at } . ( localtime $revision->{'timestamp'} ) . qq{\n};
    $text .= qq{with message:\n} . $revision->{'message'} . qq{\n};

    # TODO: have list of changed files here.

    return $text;
} # }}}

# vim: fdm=marker
1;
