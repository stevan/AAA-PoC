package AAA::Web::App::CreateAPIKey;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;

use AAA::Model::APIKey;

use Plack::Component;

our @ISA = ('Plack::Component');

sub call {
	my $self   = $_[0];
	my $env    = $_[1];
	my $accept = $env->{HTTP_ACCEPT};
			
	my ($content_type, $body) = defined $accept && $accept eq 'application/json'
		? ('application/json' => AAA::Model::APIKey->new->to_json)
		: ('text/plain'       => AAA::Util::encode_base64( AAA::Model::APIKey->new->pack ));

	return [ 200, [ 'Content-Type' => $content_type ], [ $body ] ];
}

1;

__END__

=pod

=cut