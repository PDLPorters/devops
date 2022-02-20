package PDL::Devops::Process::Docker;
# ABSTRACT: Process item with Docker

use Mu;
use Path::Tiny;

ro 'dockerfile_path';

ro 'item';

sub run {
	my ($self) = @_;
	my $item = $self->item;
	my $tag = $item->docker_tag;
	(my $module_name = $item->dist) =~ s/-/::/g;
	my $apt_pkgs = join " ", @{ $db->apt_pkgs( $item ) };
	system(
		qw(docker build),
			qw(-f ), path($self->dockerfile_path, "Dockerfile.downstream"),
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
}

1;
