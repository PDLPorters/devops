#!/usr/bin/env perl
# PODNAME: gha-ci-gen-matrix.pl
# ABSTRACT: Create matrix for GitHub Actions CI

use FindBin;
use lib "$FindBin::Bin/lib";

use Path::Tiny;
use JSON::PP qw(encode_json);

use PDL::Devops::DB;

my $DATA_PATH = path( $FindBin::Bin , '../data/project.yml' );

sub main {
	my $db = PDL::Devops::DB->new( data_path => $DATA_PATH );
	my @items = map {
		@{ $db->item_by_group->{$_} }
	} @{ $db->_data->{'downstream-testing-groups'} };
	my @keys = map { $_->should_skip ? () : +{ key => $_->key } } @items;
	my $matrix = { include => \@keys };
	print "::set-output name=project-matrix::" . encode_json($matrix) . "\n";
}

main;
