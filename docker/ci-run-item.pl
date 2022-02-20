#!/usr/bin/env perl
# PODNAME: ci-run-item.pl
# ABSTRACT: Run Docker in CI for a single key

use FindBin;
use lib "$FindBin::Bin/lib";

use Path::Tiny;

use PDL::Devops::DB;
use PDL::Devops::Process::Docker;

my $DATA_PATH = path( $FindBin::Bin , '../data/project.yml' );

sub main {
	my $key = shift @ARGV or die "Missing key";
	my $db = PDL::Devops::DB->new( data_path => $DATA_PATH );
	my $item = $db->key_to_item->{$key};
	PDL::Devops::Process::Docker->new(
		db => $db,
		dockerfile_path => $FindBin::Bin,
		item => $item,
	)->run;
}

main;
