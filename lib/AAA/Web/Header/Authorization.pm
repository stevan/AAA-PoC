package AAA::Web::Header::Authorization;

use strict;
use warnings;

our $VERSION = '0.01';

use UNIVERSAL::Object;

use AAA::Util;

our @ISA = ('UNIVERSAL::Object');
our %HAS = (
	credentials => sub { +{} }
);

sub new_from_env {
	my ($class, $env) = @_;

	my $authorizations = $env->{HTTP_AUTHORIZATION};

	my %credentials;
	foreach my $authorization ( split /\,\s+/ => $authorizations ) {
		my ($scheme, $credentials) = ($authorization =~ /^(.*)\s+(.*)$/);
		$credentials{ lc $scheme } = AAA::Util::decode_base64( $credentials );
	}

	return $class->new( credentials => \%credentials );
}

sub credentials_for_scheme {
	my ($self, $scheme) = @_;
	return $self->{credentials}->{ lc $scheme };
}

1;

__END__

=pod

=cut