package PDL::Devops::DB;
# ABSTRACT: Data for project items

use Mu;
use YAML qw(LoadFile);
use Data::Dumper::Concise;

use MooX::Struct
	Item => [
		qw( $key ),
		qw( $dist $repo ),

		qw( @apt )     => [ default => sub { [] } ],
		qw( @depends ) => [ default => sub { [] } ],

		qw( $graphical_display ) => [ default => sub { 0 } ],

		qw( $skip ) => [ default => sub { 0 } ],

		BUILDARGS => sub {
			my $class = shift;
			my $args = ref $_[0] ? $_[0] : { $_[0] };
			if( ! exists $args->{key} && exists $args->{dist} ) {
				$args->{key} = $args->{dist};
			}

			if( exists $args->{'depends-on'} ) {
				$args->{depends} = delete $args->{'depends-on'};
			}

			if( exists $args->{'graphical-display'} ) {
				$args->{graphical_display} = delete $args->{'graphical-display'};
			}

			if( ! exists $args->{key} ) {
				die "Could not create $class for arguments " . Dumper( $args );
			}

			$args;
		},

		should_skip => sub {
			my ($self) = @_;
			return $self->skip || ! defined $self->dist;
		},

		docker_tag => sub {
			my ($self) = @_;
			# A tag name must be valid ASCII and may contain
			# lowercase and uppercase letters, digits, underscores,
			# periods and dashes
			(my $tag = lc $self->key) =~ s/[^a-zA-Z0-9_.-]//g;
			$tag;
		},
	],
;

ro 'data_path';

lazy _data => sub {
	my ($self) = @_;
	my $data = LoadFile( $self->data_path );
};

rwp 'item_by_group', required => 0, init_arg => undef;
rwp 'key_to_item'  , required => 0, init_arg => undef;

sub BUILD {
	my ($self) = @_;
	my $data = $self->_data;
	my @groups = keys %{ $data->{groups} };
	my $item_by_group;
	my $key_to_item;
	for my $group (@groups) {
		for my $item (@{ $data->{groups}{$group} }) {
			my $item = Item->new( $item );
			$key_to_item->{$item->key} = $item;
			push @{ $item_by_group->{$group} }, $item;
		}
	}

	$self->_set_key_to_item( $key_to_item );
	$self->_set_item_by_group( $item_by_group );
}

lazy _items => sub {
	my ($self) = @_;
	return [ values %{ $self->_key_to_item } ];
};

lazy groups => sub {
	my ($self) = @_;
	return [ keys %{ $self->_item_by_group } ];
};

sub module_name {
	my ($self, $item) = @_;
	(my $module_name = $item->dist) =~ s/-/::/g;
	$module_name;
}

# this could also be used to layer in already-built containers
sub cpan_pkgs {
	my ($self, $item) = @_;
	my @cpan = $self->module_name($item);
	for my $deps (@{ $item->depends }) {
		unshift @cpan, @{ $self->cpan_pkgs(
			$self->key_to_item->{ $deps }
		) };
	}
	\@cpan; # order matters here - deps installed before main
}

sub apt_pkgs {
	my ($self, $item) = @_;
	my @apt = @{ $item->apt };
	for my $deps (@{ $item->depends }) {
		push @apt, @{ $self->apt_pkgs(
			$self->key_to_item->{ $deps }
		) };
	}
	[ sort @apt ];
}

1;
