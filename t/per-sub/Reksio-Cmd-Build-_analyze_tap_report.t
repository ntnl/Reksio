#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib};

use Test::More;
# }}}

use Reksio::Cmd::Build;

plan tests =>
    + 1 # 1) 'prove' from t_data/sample_tests (TAP::Harness v3.22 and Perl v5.12.2) with various failures
    + 1 # 2) 'prove' tests that pass (TAP::Harness v3.22 and Perl v5.12.2)
;

my $input_1 = # {{{
q{===(       1;0  1/4  0/? )==============================================
#   Failed test 'Case 1'
#   at all_failed.t line 9.

#   Failed test 'Case 2'
#   at all_failed.t line 10.

#   Failed test 'Third case'
#   at all_failed.t line 11.

#   Failed test 'Last (fourth) case'
#   at all_failed.t line 12.
# Looks like you failed 4 tests of 4.
all_failed.t ... Dubious, test returned 4 (wstat 1024, 0x400)           
Failed 4/4 subtests 
===(       5;0  1/4  0/? )==============================================I die here at died_after.t line 14.
# Looks like your test exited with 255 just after 4.
died_after.t ... Dubious, test returned 255 (wstat 65280, 0xff00)       
All 4 subtests passed 
died_before.t .. I die here at died_before.t line 7.
died_before.t .. Dubious, test returned 255 (wstat 65280, 0xff00)       
No subtests run 
===(       9;0  1/4  0/? )==============================================I die here at died_trough.t line 12.
# Looks like you planned 4 tests but ran 2.
# Looks like your test exited with 255 just after 2.
died_trough.t .. Dubious, test returned 255 (wstat 65280, 0xff00)       
Failed 2/4 subtests 
passing.t ...... ok                                                     
some_failed.t .. 1/8 
#   Failed test 'Case 2'
#   at some_failed.t line 10.

#   Failed test 'Case 4'
#   at some_failed.t line 12.

#   Failed test 'Case 5'
#   at some_failed.t line 13.

#   Failed test 'Case six'
#   at some_failed.t line 14.
# Looks like you failed 4 tests of 8.
some_failed.t .. Dubious, test returned 4 (wstat 1024, 0x400)
Failed 4/8 subtests 

Test Summary Report
-------------------
all_failed.t    (Wstat: 1024 Tests: 4 Failed: 4)
  Failed tests:  1-4
  Non-zero exit status: 4
died_after.t    (Wstat: 65280 Tests: 4 Failed: 0)
  Non-zero exit status: 255
died_before.t   (Wstat: 65280 Tests: 0 Failed: 0)
  Non-zero exit status: 255
  Parse errors: No plan found in TAP output
died_trough.t   (Wstat: 65280 Tests: 2 Failed: 0)
  Non-zero exit status: 255
  Parse errors: Bad plan.  You planned 4 tests but ran 2.
some_failed.t   (Wstat: 1024 Tests: 8 Failed: 4)
  Failed tests:  2, 4-6
  Non-zero exit status: 4
Files=6, Tests=22,  0 wallclock secs ( 0.05 usr  0.01 sys +  0.11 cusr  0.02 csys =  0.19 CPU)
Result: FAIL
}; # }}}

my $rep_1 = Reksio::Cmd::Build::_analyze_tap_report($input_1);
#use Data::Dumper; warn Dumper $rep_1;
is_deeply(
    $rep_1,
    { # {{{
        status => q{F},

        total_tests_count  => 6,
        total_cases_count  => 22,
        failed_tests_count => 5,
        failed_cases_count => 8,

        tests => {
            'all_failed.t' => {
                cases_count  => 4,
                failed_count => 4,
                status       => 'Failed',
            },
            'died_after.t' => {
                cases_count  => 4,
                failed_count => 0,
                status       => 'Died',
            },
            'died_before.t' => {
                cases_count  => 0,
                failed_count => 0,
                status       => 'Died',
            },
            'died_trough.t' => {
                cases_count  => 2,
                failed_count => 0,
                status       => 'Died',
            },
            'some_failed.t' => {
                cases_count  => 8,
                failed_count => 4,
                status       => 'Failed',
            },
        },
    }, # }}}
    q{various failures (TAP::Harness v3.22 and Perl v5.12.2)}
);


my $input_2 = # {{{
q{t/per-module/Reksio-Cmd-DelRepo.t .. ok
t/per-module/Reksio-API-Data.t ..... ok
All tests successful.
Files=2, Tests=29,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.32 cusr  0.03 csys =  0.39 CPU)
Result: PASS
}; # }}}

my $rep_2 = Reksio::Cmd::Build::_analyze_tap_report($input_2);
#use Data::Dumper; warn Dumper $rep_2;
is_deeply(
    $rep_2,
    { # {{{
        status => q{P},

        total_tests_count  => 2,
        total_cases_count  => 29,
        failed_tests_count => 0,
        failed_cases_count => 0,

        tests => { },
    }, # }}}
    q{all tests pass (TAP::Harness v3.22 and Perl v5.12.2)}
);

# vim: fdm=marker
