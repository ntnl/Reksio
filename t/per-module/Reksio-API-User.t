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

use Reksio::Test::Setup qw( fake_installation );

use Test::More;
# }}}

use Reksio::API::User qw( get_user_by_name get_user_by_vcs_id );

plan tests =>
    + 2 # get_user_by_name
    + 2 # get_user_by_vcs_id
;

my $basedir = fake_installation($Bin .q{/../../t_data/});



is(get_user_by_name('Foo'), undef, q{get_user_by_name - false user});
is_deeply(
    get_user_by_name('Bartłomiej Syguła'),
    {
        id => 'Bartłomiej Syguła',
        vcs_ids => [
            q{bs},
            q{bs502},
            q{bs5002},
            q{natanael},
            q{Bartłomiej Syguła},
        ],
        email => q{reksio-test@natanael.krakow.pl},
    },
    q{get_user_by_name - valid user},
);

is(get_user_by_vcs_id('Foo'), undef, q{get_user_by_vcs_id - false user});
is_deeply(
    get_user_by_vcs_id('Bartłomiej Syguła'),
    {
        id => 'Bartłomiej Syguła',
        vcs_ids => [
            q{bs},
            q{bs502},
            q{bs5002},
            q{natanael},
            q{Bartłomiej Syguła},
        ],
        email => q{reksio-test@natanael.krakow.pl},
    },
    q{get_user_by_vcs_id - valid user}
);


# vim: fdm=marker
