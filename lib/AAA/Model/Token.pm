package AAA::Model::Token;

use strict;
use warnings;

our $VERSION = '0.01';

use UNIVERSAL::Object;

use Carp        ();
use Digest::SHA ();

use AAA::Util;
use AAA::Util::Time;
use AAA::Util::Secrets;

our @ISA = ('UNIVERSAL::Object');
our %HAS = (
	key  => sub { die 'The API key is required'  },
	time => sub { AAA::Util::Time::get_timestamp() },
	body => sub {},
);

sub key  { $_[0]->{key}  }
sub time { $_[0]->{time} }
sub body { $_[0]->{body} }

sub BUILDARGS {
	my $class = shift;
	my $args  = $class->SUPER::BUILDARGS( @_ );
	Carp::confess('Invalid args, you must pass both `time` and `body` or pass neither')
		if $args->{time} && not($args->{body})
		|| $args->{body} && not($args->{time});
	return $args;
}

sub BUILD {
	my ($self, $params) = @_;

	my $body = Digest::SHA::sha1_hex( 
		join '' => $self->{time}, AAA::Util::Secrets::get_secret(), $self->{key} 
	);
	
	if ( $self->{body} ) {
		Carp::confess('Invalid token, got: ' . $self->{body} . ' expected: ' . $body)
			unless $self->{body} eq $body;
	}
	else {
		$self->{body} = $body;
	}
}

sub validate {
	my ($class, $token, $key) = @_;
	return !! eval { $class->unpack( $token, $key ) }
}

sub pack {
	my $self = $_[0];
	return join ':' => $self->{time}, $self->{body};
}

sub unpack {
	my ($class, $data, $key) = @_;
	my ($time, $body) = split /\:/ => $data;
	return $class->new( time => $time, body => $body, key => $key );
}

sub to_json {
	my $self = $_[0];
	return AAA::Util::JSON->encode({ time => $self->{time}, body => $self->{body}, key => $self->{key} })
}

sub from_json {
	my ($class, $json) = @_;
	return $class->new( AAA::Util::JSON->decode( $json ) );
}

1;

__END__

=pod

=head1 NAME

AAA::Model::Token - Model for API Keys

=head1 SYNOPSIS

	my $token = AAA::Model::Token->new;

	say $token->id; 
	say $token->key; 

	my $packed = $token->pack;

	my $token2 = AAA::Model::Token->unpack( $packed );

	# $token->id  eq $token2->id && $token->key eq $token2->key 

=head1 DESCRIPTION

This is a lexigraphically sortable UID in the form:

	[[timestamp][randomness]]

And due to the (monotonic) timestamp being at the start we can be 
sure that the overall UID is sortable. 

Since we know the time the token was issued, we can also easily 
calculate it's age, which means we can expire it very easily.

To reduce the space needed for the timestamp, it is possible to 
have a custom epoch as well. 

The randomness potion could be anything, including something related 
to the Key.

Ideally this also has the property of not needing storage and being 
self validating (minus some kind of distributed secret) 

=head1 SEE ALSO

L<https://tools.ietf.org/html/draft-hammer-http-token-auth-01>

=cut