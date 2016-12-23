package AAA::Web::App::CreateToken;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;

use AAA::Model::Token;
use AAA::Model::APIKey;

use AAA::Web::Header::Authorization;

use Plack::Component;

our @ISA = ('Plack::Component');

sub call {
	my $self   = $_[0];
	my $env    = $_[1];
	my $accept = $env->{HTTP_ACCEPT};
	my $key    = $env->{'aaa.api_key'};    

	if ( not $key ) {
		my $h = AAA::Web::Header::Authorization->new_from_env( $env );
		if ( my $creds = $h->credentials_for_scheme( 'APIKey' ) ) {
			$key = AAA::Model::APIKey->unpack( $creds );
		}
	}

	return [ 500, [],['Unable to find valid API key'] ] unless $key;

	my ($content_type, $body) = defined $accept && $accept eq 'application/json'
		? ('application/json' => AAA::Model::Token->new( key => $key )->to_json)
		: ('text/plain'       => AAA::Util::encode_base64( AAA::Model::Token->new( key => $key )->pack ));

	return [ 200, [ 'Content-Type' => $content_type ], [ $body ] ];
}

1;

__END__

=pod

=cut