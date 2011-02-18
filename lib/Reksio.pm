package Reksio;
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

# }}}

=pod

=encoding UTF-8

=head1 NAME

Reksio - Continuous Integration and Testing Server

=head1 SYNOPSIS

 # Process current work and quit:
 reksio_dispatch --single

 # Monitor repositories, run builds and generate reports as needed, in the background.
 reksio_dispatch &

=head1 DESCRIPTION

Reksio aims to monitor predefined list of software repositories (VCS, DVCS as well as tar/zip archives),
checkout and build new versions as they become available, providing feedback about the build process and it's results.

By doing continous integration and testing it saves developer's time and improves stability and quality.

Final goal for the project is to support large - in terms of complexity and people involved - projects,
both open source and commercial.

=head1 INSTALL

Reksio is distributed as a standard I<Module::Build> based archive.

Please download the latest stable release, and run the following:

 tar xzf Reksio-x.y.z.tar.gz
 cd Reksio-x.y.z.tar.gz
 ./Build.PL
 ./Build
 ./Build test
 ./Build install

Test step is optional, but recomended. It will ensure, that Reksio works corectly on your system/architecture.
If this step fails, please contact the Author.

Currently Reksio is known to work on Linux, will probably run on any *NIX system, and will probably fail on Windows.

Windows support is planned for future.

At this moment, there was no demand for the module to be available trough CPAN.
If you would like it to be available there, please email the Author.

=head1 CONFIGURATION

=head2 Basic server setup

Server will look for it's basic configuration file in the following locations:

 $REKSIO_CONFIG
 ./.reksio.conf
 ~/.reksio.conf
 /etc/reksio.conf

Basic configuration file is a YAML-serialized hash with configuration options.
Different functionality requires different options, thus there is not a single set of requirements.
However, since unused options are ignored, it is better so provide to much, then too little information.

Example configuration file is shown bellow.

 ---
 workspace:     "/home/reksio/workspace/"
 build_results: "/home/reksio/buildlogs/"
 users_file:    "/home/reksio/users.yaml"
 db:            "sqlite:/home/reksio.sqlite"

Please note, that the directories have to exist (please create them).

You must also prepare an SQL database for Reksio to use.

Once the server is configured, you can prepare database for it to use.

=head2 Setting up database

Reksio can use virtually any Database supported by Perl trough the DBI library.

It is known to work with SQLite vesion 3.7.0 and above.

At this stage, Database has to be initialized using tools provided by the DB.
SQL structure is provided to ease the task. Please create an empty (with no tables/indexes/etc) database,
and initialize it by importing provided F<structure.sql> file.

Please refer to your Database's manual, to check how to import this file.

As an example, to initialize an SQLite database, please run the following command:

 $ sqlite3 -init data/sql/v0.1/structure.sql database.sqlite '/* */'

Once the DB is set-up, you can set-up Repositories.

=head2 Repository setup

Please add reposotories that you like Reksio to watch for using the I<reksio_add_repository> command.

Once repository is added, you can define Builds.

=head2 Build setup

Add builds using the I<reksio_add_build> command.

Each repository may have one, or more builds defined in it.

Builds can not be shared, but more then one repository can have identically configred Build.

Note, that Reksio will start watching a reposotory only, if it has builds.

=head2 Test setup

Reksio understands Perl's native TAP protocol.

Example test commands:

 prove t/
    # Run all tests from 't' directory.

 prove -j 2 t/* t/*/*/
    # Run tests from 't' and it's sub-directories, up to two in parallel.

See L<prove> for more details how to use the Test harness.

Support for parsing JUnit-based output is planed for future.

=head2 Setting up contact information

Reksio needs contact information to be provided to him, in order to be able to send reports to correct email adresses.

To do this, provide a "Users file", that is a YAML-serialized data structure, containing VCS ID to User to Email mapping.
See the example bellow:

  ---
  "Bartek S.":
    email: reksio-test@natanael.krakow.pl
    vcs_ids:
    - bs
    - bs502
    - bs5002
    - natanael
    - "Bartłomiej Syguła"
  "Automaton":
    email: auto@reksio-project.org
    vcs_ids:
    - auto

Note: this mechanizm is a temporal maesure. In future versions, this information will be incorporated into the main DB.

=head2 Starting the server

Reksio supports two ways, in which it can operate.

=over

=item Running in the background as server

Reksio can continously watch for new commits/archives and build those, as needed.

For this to work, leave I<reksio_dispatch> running in the background, for example, by running:

 reksio_dispatch > reksio.log 2>&1 &

This is the recommended way of using I<reksio_dispatch>.

Tip: Another way of putting processes into background, is to run them in I<screen>.

=item Running from cron

You can configure the I<cron> scheduled to run I<reksio_dispatch --single> command at times most conveneient for your environment.

This allows, for example, to check for updateds more ofted during the day, and less ofted during the night.

Please provide long-enough (this depends on the server speed, repository size, etc) delays for one dispatch/build/test/report run to finish,
before the next one starts.

Example I<crontab> entry, that runs dispatch process once per hour, is bellow:

 10  *  * * *  reksio  reksio_dispatch --single

=back

=head3 

=head1 DOCUMENTATION

The following documentation is also awailable:

=over

=item Shell commands reference

See L<Reksio::Cmd>

=item Software repositories support

See: L<Reksio::VCS>

=item Internal API reference

See L<Reksio::API>

=item Testing and QA

See L<Reksio::Test>

=back

=head1 DEVELOPEMENT

Reksio development follows three major Agile guidelines: release quickly, release often, every release gives the User some visible improvements.

Quality and maintenability is an important aspect for the project. To ensure that, Reksio watches over it's own codebase since
first public release. Automated test suit covers more then 95% of the codebase.

Knowing that Perl has reputation of being hard-to-read language, We follow many PerlCritic rules, to ensure that the code
remains readable, and complemented by extensive documentation.

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

More information on: L<http://reksio-project.org/>

=cut

# vim: fdm=marker
1;
