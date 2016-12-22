#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;

use Plack::Middleware::Auth::Basic;
use Plack::Middleware::Auth::AccessToken;

use Plack::App::Proxy;

use MIME::Base64 ();

use AAA::Model::APIKey;
use AAA::Model::Token;

use AAA::Web::Middleware::Auth;

builder {

	# key management ...
	mount '/api-key' => builder {
		mount '/create' => sub {
			my $env    = $_[0];
			my $accept = $env->{HTTP_ACCEPT};
			
			my ($content_type, $body) = $accept eq 'application/json'
				? ('application/json' => AAA::Model::APIKey->new->to_json)
				: ('text/plain'       => MIME::Base64::encode_base64( AAA::Model::APIKey->new->pack, '' ));

			return [200, ['Content-Type', $content_type], [$body]];
		};
	};

	# the proxy ...
	mount '/' => builder {
		# make sure they have a Key
		enable '+AAA::Web::Middleware::Auth', scope => 'APIKey';
		# token management (behind api-key)
		mount '/token' => builder {
			mount '/create' => sub {
				my $env    = $_[0];
				my $accept = $env->{HTTP_ACCEPT};
				my $key    = $env->{'aaa.api_key'};    

				my ($content_type, $body) = $accept eq 'application/json'
					? ('application/json' => AAA::Model::Token->new( key => $key )->to_json)
					: ('text/plain'       => MIME::Base64::encode_base64( AAA::Model::Token->new( key => $key )->pack, '' ));

				return [200, ['Content-Type', $content_type], [$body]];
			};
		};

		mount '/' => builder {
			# make sure they have a Token
			enable '+AAA::Web::Middleware::Auth', scope => 'Token';
			# and finally, services ...
			mount '/' => Plack::App::Proxy->new( remote => 'http://0:5000/' )->to_app;
		};
	}
};