#!/usr/bin/perl

use strict; use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Reksio',
    license     => 'perl',

    configure_requires => {
        'Module::Build' => 0.34
    },
    requires => {
        'perl' => '5.10.0',

        'Carp::Assert::More' => q{1.10},
        'DBI'                => q{1.611},
        'Digest::MD5'        => q{2.39},
        'File::Slurp'        => q{9999.13},
        'Getopt::Long'       => q{2.36},
        'Git::Repository'    => q{1.14},
        'MIME::Lite'         => q{3.025},
        'Params::Validate'   => q{0.95},
        'SQL::Abstract'      => q{1.61},
        'YAML::Any'          => q{0.72},

        # Left for future reference:
#        'Some::Module'  => '1.23',
#        'Other::Module' => '>= 1.2, != 1.5, < 2.0',
    },
    build_requires => {
        'Test::More'  => q{0.94},
        'DBD::SQLite' => q{1.29},
    },

    recursive_test_files => 1,
);
$build->create_build_script();

# vim: fdm=marker
