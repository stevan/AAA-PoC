package AAA::Model::APIKey;

use strict;
use warnings;

our $VERSION = '0.01';

use UNIVERSAL::Object;

use Carp       ();
use Data::UUID ();

use AAA::Util;
use AAA::Util::Secrets;

our @ISA = ('UNIVERSAL::Object');
our %HAS = (
	id  => sub { my $uuid = Data::UUID->new; $uuid->to_string( $uuid ) },
	key => sub {}
);

sub BUILD {
	my ($self, $params) = @_;

	my $key = AAA::Util::Secrets::get_digest_of( $self->{id} );
	
	if ( $self->{key} ) {
		Carp::confess('Invalid key, got: ' . $self->{key} . ' expected: ' . $key)
			if $self->{key} ne $key;
	}
	else {
		$self->{key} = $key;
	}
}

sub id  { $_[0]->{id}  }
sub key { $_[0]->{key} }

sub validate {
	my ($class, $apikey) = @_;
	return !! eval { $class->unpack( $apikey ) };
}

sub pack {
	my $self = $_[0];
	return join ':' => $self->{id}, $self->{key};
}

sub unpack {
	my ($class, $data) = @_;
	my ($id, $key) = split /\:/ => $data;
	return $class->new( id => $id, key => $key );
}

sub to_json {
	my $self = $_[0];
	return AAA::Util::JSON->encode({ id => $self->{id}, key => $self->{key} })
}

sub from_json {
	my ($class, $json) = @_;
	return $class->new( AAA::Util::JSON->decode( $json ) );
}

1;

__END__

=pod

=head1 NAME

AAA::Model::APIKey - Model for API Keys

=head1 SYNOPSIS

my $key = AAA::Model::APIKey->new;

say $key->id; 
say $key->key; 

my $packed = $key->pack;

my $key2 = AAA::Model::APIKey->unpack( $packed );

# $key->id  eq $key2->id && $key->key eq $key2->key 

=head1 DESCRIPTION

An API key is a combination of two values, an `id` and `key` 
(think "username & password" if you will). The `id` is a UUID 
that we generate and the password is the UUID hashed with a 
secret that only we know about. This means that we can check 
the vailidity of the pair simply by distributing a secret, and 
not needing any centralized storage. 

This also allows us to use HTTP Basic Auth to actually pass 
these back and forth, so it is super easy to handle. 

=head1 SEE ALSO

L<https://tools.ietf.org/html/rfc2617>

=cut


