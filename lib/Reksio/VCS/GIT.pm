package Reksio::VCS::GIT;
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
use base q{Reksio::VCS};

my $VERSION = '0.1.0';

use Digest::MD5 qw( md5_hex );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Git::Repository qw( Log );
# }}}

sub vcs_revisions { # {{{
    my ($self, $start_at) = @_;
    
    my $repo = $self->_bare_copy_location();

    my @logs;
    if ($start_at) {
        @logs = $repo->log( $start_at . q{..HEAD}, q{-n}, q{100} );
    }
    else {
        @logs = $repo->log( q{-n}, q{100} );
    }

    my @revisions;
    foreach my $item (@logs) {
#        use Data::Dumper; warn Dumper $item;

        my $message = $item->message();
        chomp $message;

        my $parent = undef;
        if ($item->{'parent'}) {
            $parent = $item->{'parent'}->[0];
        }

        push @revisions, {
            commit_id => $item->commit(),

            timestamp => $item->{'author_gmtime'},
            commiter  => $item->{'committer_name'},
            message   => $message,

            parent    => $parent,
        };
    }

    return \@revisions;
} # }}}

sub vcs_checkout { # {{{
    my ($self, $sandbox_folder, $commit_id) = @_;

    # FIXME: add --no-checkout
    my $repo = Git::Repository->create(clone => $self->uri() => $sandbox_folder);

    $repo->command('checkout', $commit_id);

    return;
} # }}}

################################################################################
#                       Private methods.
################################################################################

sub _bare_copy_location { # {{{
    my ( $self ) = @_;

    # Do We already have some bare copy?
    if (not $self->{'VCS'}->{'Bare_Repo'}) {
        my $_bare_copy_location = sprintf q{/tmp/bare_copy_%s_%d}, md5_hex($self->uri()), $PID;

        if (-d $_bare_copy_location) {
            $self->{'VCS'}->{'Bare_Repo'} = Git::Repository->new(git_dir => $_bare_copy_location .q{/.git});
        }
        else {
            # FIXME! Add --bare option!!!
            $self->{'VCS'}->{'Bare_Repo'} = Git::Repository->create(clone => $self->uri() => $_bare_copy_location);
        }
    }

    return $self->{'VCS'}->{'Bare_Repo'};
} # }}}

#END {
#    # Clean any bare copy, that We have created...
#    # TODO
#}

# vim: fdm=marker
1;
