#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;

use Plack::App::Proxy;

use AAA::Model::APIKey;
use AAA::Model::Token;

builder {

	# key management ...
	mount '/api-key' => builder {
		mount '/create' => sub {
			my $env          = $_[0];
			my $accept       = $env->{HTTP_ACCEPT};
			
			my ($content_type, $body) = $accept eq 'application/json'
				? ('application/json' => AAA::Model::APIKey->new->to_json)
				: ('text/plain'       => AAA::Model::APIKey->new->pack);

			return [200, ['Content-Type', $content_type], [$body]];
		};
	};

	# the proxy ...
	mount '/' => builder {
		enable "Auth::Basic", authenticator => sub {
			my ($id, $key, $env) = @_;
			return AAA::Model::APIKey->validate( $id, $key );
		};

		Plack::App::Proxy->new( remote => 'http://0:5000/' )->to_app;
	}
};