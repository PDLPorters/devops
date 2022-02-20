#!/usr/bin/env perl
# PODNAME: docker-runner
# ABSTRACT: Run docker downstream deps

use FindBin;
use lib "$FindBin::Bin/lib";
use Path::Tiny;
use Parallel::ForkManager;

use PDL::Devops::DB;

my $procs = 0;
my $pm = Parallel::ForkManager->new($procs);

my $DATA_PATH = path( $FindBin::Bin , '../data/project.yml' );

sub main {
	my $db = PDL::Devops::DB->new( data_path => $DATA_PATH );

	my $cpan_downstream = $db->item_by_group->{'cpan-downstream'};
	DATA_LOOP:
	for my $item (@$cpan_downstream) {
		next if $item->should_skip;

		my $pid = $pm->start and next DATA_LOOP;

		print "Working on @{[ $item->key ]}\n";
		my $tag = $item->docker_tag;
		(my $module_name = $item->dist) =~ s/-/::/g;
		my $apt_pkgs = join " ", @{ $db->apt_pkgs( $item ) };
		system(
			qw(docker build),
				qw(-f ), path($FindBin::Bin, "Dockerfile.downstream"),
				qw(-t), "pdl-dep:$tag",
				( $item->graphical_display
				? (
					#qw(--build-arg), "BASE_CONTAINER=pdl-graphical:latest",
					qw(--build-arg), "START_XVFB=true",
				  )
				: ()
				),
				qw(--build-arg), "CPANM_ARGS=$module_name",
				( $apt_pkgs
				? ( qw(--build-arg), "APT_PKGS=$apt_pkgs", )
				: ()
				),
				'.',
		) == 0 or die "Could not build @{[ $item->dist ]}";

		$pm->finish;
	}
}

main;
