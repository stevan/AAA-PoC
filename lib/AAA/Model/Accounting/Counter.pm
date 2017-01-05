package AAA::Model::Accounting::Counter;

use strict;
use warnings;

our $VERSION = '0.01';

use UNIVERSAL::Object;

our @ISA = ('UNIVERSAL::Object');
our %HAS = (
	count    => sub { 0   },
	per_path => sub { +{} },
);

sub count    { $_[0]->{count}    }
sub per_path { $_[0]->{per_path} }

sub add_path {
	my ($self, $path) = @_;
	$self->{count}++;
	$self->{per_path}->{$path}++;
}

sub track {
	my ($self, $env) = @_;
	$self->add_path( $env->{PATH_INFO} );
}

sub pack { +{ %{ $_[0] } } }

sub to_json { AAA::Util::JSON->encode( $_[0]->pack ) }

1;

__END__

=pod

=cut


