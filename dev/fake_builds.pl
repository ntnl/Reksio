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
use lib $Bin .q{/../lib};

use Reksio::API::Data qw( add_repository add_build );
use Reksio::Cmd::Build;
use Reksio::Cmd::Inspect;
use Reksio::Cmd::ScheduleBuild;
use Reksio::Test::Setup qw( fake_installation fake_repository );
use Reksio::VCS::GIT;
# }}}

my $basedir = fake_installation($Bin .q{/../t_data/});
my $repo_path = fake_repository($Bin .q{/../t_data});

#warn $repo_path;

my $rep1_id = add_repository(name => 'Test', vcs=>'GIT', uri=>$repo_path);
my $b1_id = add_build(
    repository_id => $rep1_id,

    name => 'Prove',

    test_command => 'prove t/',

    frequency        => 'EACH',
    test_result_type => 'TAP'
);

Reksio::Cmd::Inspect::main(q{--repo=Test});

my $vcs_handler = Reksio::VCS::GIT->new(
    uri => $repo_path,
);

my $revisions = $vcs_handler->revisions();

# FIXME: This thing with $i is a DIRTY HACK!
my $i = 1;
foreach my $rev (@{ $revisions }) {
    print "Building: ". $rev->{'commit_id'} ."\n";

    Reksio::Cmd::ScheduleBuild::main('--repo=Test', '--build=Prove', '--commit='.$rev->{'commit_id'});

    Reksio::Cmd::Build::main(q{--result_id=} . $i);

    $i++;
}

#system q{tree }. $basedir;

system q{cd }. $basedir .q{ && tar czf }. $Bin .q{/../t_data/test_install.tgz ./};

# vim: fdm=marker
