#!/usr/bin/env perl
# PODNAME: docker-runner
# ABSTRACT: Run docker downstream deps

use FindBin;
use lib "$FindBin::Bin/lib";

use Getopt::Long;
use Pod::Usage;

use Path::Tiny;
use Parallel::ForkManager;

use PDL::Devops::DB;
use PDL::Devops::Process::Docker;

my $DATA_PATH = path( $FindBin::Bin , '../data/project.yml' );

sub main {
	my $procs = 0; # run without fork
	my $verbose = 0;
	my $help = 0;
	GetOptions(
		"jobs=i"  => \$procs,
		"verbose" => \$verbose,
		"help"    => \$help )
		or die("Error in command line arguments\n");
	pod2usage(1) if $help;

	my $pm = Parallel::ForkManager->new($procs);

	my $db = PDL::Devops::DB->new( data_path => $DATA_PATH );

	my @items = map {
		@{ $db->item_by_group->{$_} }
	} @{ $db->_data->{'downstream-testing-groups'} };
	DATA_LOOP:
	for my $item (@items) {
		next if $item->should_skip;

		my $pid = $pm->start and next DATA_LOOP;

		print "Working on @{[ $item->key ]}\n" if $verbose;
		PDL::Devops::Process::Docker->new(
			db => $db,
			dockerfile_path => $FindBin::Bin,
			item => $item,
		)->run;

		$pm->finish;
	}
}

main;
__END__

=head1 NAME

docker-runner.pl - Run all downstream testing in Docker

=head1 SYNOPSIS

docker-runner.pl [options]

 Options:
   --help     brief help message
   --jobs N   run N jobs in parallel

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--jobs>

Run N jobs in parallel.

=back

=head1 DESCRIPTION

This script reads the project data file and runs downstream testing for all
projects using Docker.

=cut
