#!/usr/bin/env perl
# PODNAME: docker-runner
# ABSTRACT: Run docker downstream deps

use FindBin;
use YAML qw(LoadFile);
use Path::Tiny;
use Parallel::ForkManager;

my $procs = 0;
my $pm = Parallel::ForkManager->new($procs);

my $DATA_PATH = path( $FindBin::Bin , '../data/repo.yml' );

sub main {
	my $data = LoadFile( $DATA_PATH );
	my $cpan_downstream = $data->{groups}{'cpan-downstream'};
	DATA_LOOP:
	for my $item (@$cpan_downstream) {
		next unless exists $item->{dist};
		next if exists $item->{skip};

		my $pid = $pm->start and next DATA_LOOP;

		print "Working on $item->{dist}\n";
		(my $tag = lc $item->{dist}) =~ s/[^a-z0-9]//g;
		(my $module_name = $item->{dist}) =~ s/-/::/g;
		my $apt_pkgs = join " ", sort @{ $item->{apt} // [] };
		system(
			qw(docker build),
				qw(-f Dockerfile.downstream),
				qw(-t), "pdl-dep:$tag",
				( $item->{'graphical-display'}
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
		) == 0 or die "Could not build $item->{dist}";

		$pm->finish;
	}
}

main;
