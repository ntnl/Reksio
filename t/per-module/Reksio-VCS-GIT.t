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

use Reksio::API::Data qw( add_repository );
use Reksio::Test::Setup qw( fake_installation );

use English qw( -no_match_vars );
use File::Slurp qw( write_file );
use Test::More;
# }}}

# FIXME:
#   This test needs git. Skip it, if there is no 'git' on the system!

plan tests =>
    + 1 # ->new()
    + 4 # revisions() - with and without starting point.
    + 2 # checkout()
;

my $basedir = fake_installation($Bin .q{/../../t_data/});
my $repo1_id = add_repository(name => 'First', vcs=>'GIT', uri=>'git://foo/bar');
my $repo2_id = add_repository(name => 'Other', vcs=>'CVS', uri=>'cvs://bar/baz');

# Prepare the source test repository. {{{
# (FIXME) the way it's done is lame. But, hey! Let's get it running first!
my $source_path = q{/tmp/git_test_repo_} . $PID . q{/};
mkdir $source_path;
chdir $source_path;
system q{tar}, q{xzf}, $Bin .q{/../../t_data/test_repo.tgz};
#system q{tree}, $source_path;
chdir $Bin;

my $sandbox_path = q{/tmp/git_test_sandbox_} . $PID . q{/};
mkdir $sandbox_path;

END {
    note("Cleaning test repo ($source_path)");
    system q{rm}, q{-rf}, $source_path;
    system q{rm}, q{-rf}, $sandbox_path;
}
# }}}


use Reksio::VCS::GIT;

my $vcs_handler = Reksio::VCS::GIT->new(
    uri => $source_path .q{test_repo},
);

isa_ok($vcs_handler, q{Reksio::VCS::GIT});

#use Data::Dumper; warn Dumper $vcs_handler->revisions();

is_deeply(
    $vcs_handler->revisions(),
    [ # {{{
        {
            'commit_id' => 'adb6ac8a75cfb12c73261abbcd4a047759d61597',
            'parent'    => undef,
            'timestamp' => 1297338154,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'First test',
        },
        {
            'commit_id' => '0524ac242831389745960abefa3f4329a0f7e730',
            'parent'    => 'adb6ac8a75cfb12c73261abbcd4a047759d61597',
            'timestamp' => 1297338216,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Second test added.',
        },
        {
            'commit_id' => 'dfab002bc60ce992d235c0c3ecbeaad92c5e703c',
            'parent'    => '0524ac242831389745960abefa3f4329a0f7e730',
            'timestamp' => 1297338310,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Third (failing) test added.',
        },
        {
            'commit_id' => '815a65c4202092bd9f43f08c4d0090721224c2a0',
            'parent'    => 'dfab002bc60ce992d235c0c3ecbeaad92c5e703c',
            'timestamp' => 1297338336,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Exec rights in place.',
        },
        {
            'commit_id' => '3b06d05a012e8b25354e4d60498f07ce36962fb1',
            'parent'    => '815a65c4202092bd9f43f08c4d0090721224c2a0',
            'timestamp' => 1297338432,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Third test "fixed" ;)',
        },
    ], # }}}
    q{revisions() without starting point}
);

is_deeply(
    $vcs_handler->revisions(q{dfab002bc60ce992d235c0c3ecbeaad92c5e703c}),
    [ # {{{
        {
            'commit_id' => '815a65c4202092bd9f43f08c4d0090721224c2a0',
            'parent'    => 'dfab002bc60ce992d235c0c3ecbeaad92c5e703c',
            'timestamp' => 1297338336,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Exec rights in place.',
        },
        {
            'commit_id' => '3b06d05a012e8b25354e4d60498f07ce36962fb1',
            'parent'    => '815a65c4202092bd9f43f08c4d0090721224c2a0',
            'timestamp' => 1297338432,
            'commiter'  => 'Bartłomiej Syguła',
            'message'   => 'Third test "fixed" ;)',
        },
    ], # }}}
    q{revisions() with starting point}
);

# Let's commit something, and see if it will show up on revisions list.

write_file($source_path . q{test_repo/fake.txt}, q{Sample file});
system q{cd }. $source_path .q{test_repo && git add fake.txt >/dev/null 2>&1};
system q{cd }. $source_path .q{test_repo && git commit -m 'Test' >/dev/null 2>&1};

my $revs = $vcs_handler->revisions(q{dfab002bc60ce992d235c0c3ecbeaad92c5e703c});

#use Data::Dumper; warn Dumper $revs;
ok( $revs->[2], q{revisions() - slurps new revisions});
ok( $revs->[2]->{'timestamp'} > 1298665770, q{revisions() - ... really new});


$vcs_handler->checkout($sandbox_path, 'adb6ac8a75cfb12c73261abbcd4a047759d61597');

is( -f $sandbox_path .q{/t/first_test.t},  1,     q{checkout - first file exists (as should be)});
is( -f $sandbox_path .q{/t/second_test.t}, undef, q{checkout - second file missing (as should be)});

#system q{tree}, $sandbox_path;

# vim: fdm=marker
