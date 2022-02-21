#!/usr/bin/env perl
# PODNAME: docker-runner
# ABSTRACT: Run docker downstream deps

use FindBin;
use lib "$FindBin::Bin/lib";
use Path::Tiny;
use Parallel::ForkManager;

use PDL::Devops::DB;
use PDL::Devops::Process::Docker;

my $procs = 0;
my $pm = Parallel::ForkManager->new($procs);

my $DATA_PATH = path( $FindBin::Bin , '../data/project.yml' );

sub main {
	my $db = PDL::Devops::DB->new( data_path => $DATA_PATH );

	my @items = map {
		@{ $db->item_by_group->{$_} }
	} @{ $db->_data->{'downstream-testing-groups'} };
	DATA_LOOP:
	for my $item (@items) {
		next if $item->should_skip;

		my $pid = $pm->start and next DATA_LOOP;

		print "Working on @{[ $item->key ]}\n";
		PDL::Devops::Process::Docker->new(
			db => $db,
			dockerfile_path => $FindBin::Bin,
			item => $item,
		)->run;

		$pm->finish;
	}
}

main;
