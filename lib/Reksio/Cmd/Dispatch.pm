package Reksio::Cmd::Dispatch;
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
use Reksio::API::Data qw( get_repositories get_builds get_revisions update_revision get_results schedule_build update_result );
use Reksio::Cmd;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
# }}}

sub main { # {{{
    my (@params) = @_;

    my @param_config = (
        {
            param => q{single},
            desc  => q{Do just a single round, then exit.},
            type  => q{},

            required => 0,
        },
    );

    my $options = ( Reksio::Cmd::main(\@param_config, \@params) or return 0 );

    print "Dispatch : started\n";

    # Note:
    #   Since at any time a repository or build can be added or changed,
    #   in each loop their data is re-read from DB. This is not a huge amount of
    #   data, so it should not cause problems.
    while (1) {
        my $repos = get_repositories();

        # This flag will be raised when at least one Build or Report was made.
        my $i_did_something = 0;

        # Process repository after repository.
        # Probably for near future, Reksio will not be used by BIG projects,
        # so a simple round-robin algorytm should be OK.
        foreach my $repo (_id_sort($repos)) {
            # Get builds for this repository.
            # This is because if it has none - We will not inspect it.
            my $builds = get_builds(
                repository_id => $repo->{'id'},
            );
            
            my %build_by_id;
            foreach my $build (_id_sort($builds)) {
                $build_by_id{$build->{'id'}} = $build;
            }

            if (not scalar @{ $builds }) {
                # No builds - skip this repository.
                next;
            }
    
            printf "Dispatch : inspecting repository: '%s'\n", $repo->{'name'};

            # Inspect the repository.
            run_command(q{Inspect}, q{--repo}, $repo->{'name'});

            # Search for revisions, that require Building.
            my $revisions = get_revisions(
                repository_id => $repo->{'id'},
                status        => 'N',
            );

            # If there are revisions, check if they should be scheduled...
            if (scalar @{ $revisions }) {
                my %revisions_processed;

                # Check what kind of builds there are, and schedule them.
                foreach my $build (_id_sort($builds)) {
                    if ($build->{'frequency'} eq 'EACH') {
                        # This build has to be scheduled for each revision in this repository.
                        foreach my $revision (_id_sort($revisions)) {
                            schedule_build(
                                revision_id => $revision->{'id'},
                                build_id    => $build->{'id'},
                            );

                            update_revision(
                                id => $revision->{'id'},

                                status => 'S',
                            );

                            $revisions_processed{$revision->{'id'}} = 1;
                        }

                        next;
                    }

                    if ($build->{'frequency'} eq 'RECENT') {
                        # Build just the most recent revision.

                        die("Not implemented yet!"); # FIXME: Implement!
                        # Note to self:
                        #   It is simple to implement the Build part, but Reporting has to know that it has to compare not with n-1 commit,
                        #   but with n-m commit instead.

                        next;
                    }

                    if ($build->{'frequency'} eq 'HOURLY') {
                        # Build most recent revision, only if there was at least an hour since last build.

                        die("Not implemented yet!"); # FIXME: Implement!
                        # Note to self:
                        #   It is simple to implement the Build part, but Reporting has to know that it has to compare not with n-1 commit,
                        #   but with n-m commit instead.

                        next;
                    }

                    if ($build->{'frequency'} eq 'DAILY') {
                        # Build most recent revision, but only once per day.

                        die("Not implemented yet!"); # FIXME: Implement!
                        # Note to self:
                        #   It is simple to implement the Build part, but Reporting has to know that it has to compare not with n-1 commit,
                        #   but with n-m commit instead.

                        next;
                    }

                    # There can be a 'PAUSED' frequency too,
                    # meaning "do not run this build at all".
                    # This is implementing simply by ignoring such build...
                }

                # At this point, revisions, that should be processed, should have the 'S' flag set.
                # All others should get a 'D' (Done).
                foreach my $revision (_id_sort($revisions)) {
                    if (not $revisions_processed{$revision->{'id'}}) {
                        # This revision will not be processed by any build, We are done with it.
                        update_revision(
                            id => $revision->{'id'},

                            status => 'D',
                        );
                    }
                }
            }

            # Check for any scheduled builds.
            # Those can be the ones We just scheduled, but also those scheduled (or re-scheduled) manually.
            my $results_to_build = get_results(
                build_id => [ keys %build_by_id ],

                build_status => [qw( N )],
            );

            # Run Builds :)
            my $builds_done = 0;
            foreach my $result (_id_sort($results_to_build)) {
                printf "Dispatch : building '%d'\n", $result->{'id'};

                update_result(
                    id => $result->{'id'},

                    build_status => q{S},
                );

                run_command(q{Build}, q{--result_id}, $result->{'id'});

                $i_did_something = 1;

                $builds_done++;
                if ($builds_done >= 10) {
                    printf "Dispatch : switching to other work after 10 reports.\n";
                    last;
                }
            }

            # Check if there are Results, that Reksio should report about?
            my $results_to_report = get_results(
                build_id => [ keys %build_by_id ],

                report_status => [qw( B )],
            );

            # Run reports :)
            my $reports_done = 0;
            foreach my $result (_id_sort($results_to_report)) {
                printf "Dispatch : reporting about '%d'\n", $result->{'id'};

                update_result(
                    id => $result->{'id'},

                    report_status => q{S},
                );

                run_command(q{Report}, q{--result_id}, $result->{'id'});

                $i_did_something = 1;

                $reports_done++;
                if ($reports_done >= 10) {
                    printf "Dispatch : switching to other work after 10 reports.\n";
                    last;
                }
            }
        }

        if ($options->{'single'}) {
            print "Dispatch : single round complete.\n";
            last;
        }

        if (not $i_did_something) {
            print "Dispatch : idle run, going to sleep for a while.\n";
            sleep 75; # FIXME: This should be configurable!
        }
    }

    print "Dispatch : ended.\n";

    return 0;
} # }}}

=item _id_sort($stuff)

Purpose: Sort hashrefs inside an arrayref using value from 'id' key.

=cut

sub _id_sort { # {{{
    my ( $stuff ) = @_;

    return sort { $a->{'id'} <=> $b->{'id'} } @{ $stuff };
} # }}}

sub run_command { # {{{
    my ( $command, @params ) = @_;

    # FIXME: fork would be cool here :)

    my $command_module = q{Reksio/Cmd/} . $command . q{.pm};

    require $command_module;

    my $main_sub_name = q{Reksio::Cmd::} . $command . q{::main};

    my $main_sub = \&{ $main_sub_name };

    return $main_sub->(@params);
} # }}}

# vim: fdm=marker
1;
