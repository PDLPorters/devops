package PDL::Devops::Process::Docker;
# ABSTRACT: Process item with Docker

use Mu;
use Path::Tiny;

ro 'db';

ro 'dockerfile_path';

ro 'item';

sub run {
	my ($self) = @_;
	my $item = $self->item;
	my $db = $self->db;
	my $tag = $item->docker_tag;
	my @cpan_pkgs = @{ $db->cpan_pkgs( $item ) };
	my $main_module = pop @cpan_pkgs; # last, deps go before
	my $dep_modules = join(" ", @cpan_pkgs) || 'strict';
	my $apt_pkgs = join " ", @{ $db->apt_pkgs( $item ) };
	my @cmd = (
		qw(docker build),
			qw(-f), path($self->dockerfile_path, "Dockerfile.downstream"),
			qw(-t), "pdl-dep:$tag",
			( $item->graphical_display
			? (
				#qw(--build-arg), "BASE_CONTAINER=pdl-graphical:latest",
				qw(--build-arg), "START_XVFB=true",
			)
			: ()
			),
			qw(--build-arg), "CPANM_CONFIGURE_DEPS=$dep_modules",
			qw(--build-arg), "CPANM_ARGS=$main_module",
			( $apt_pkgs
			? ( qw(--build-arg), "APT_PKGS=$apt_pkgs", )
			: ()
			),
			'.',
	);
	system(@cmd) == 0 or die "Could not build @{[ $item->key ]}";
}

1;
