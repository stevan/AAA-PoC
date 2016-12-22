#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

use Plack::App::Proxy;

use AAA::Web::App::CreateAPIKey;
use AAA::Web::App::CreateToken;

use AAA::Web::Middleware::Auth;

builder {
	# key management ...
	mount '/api-key/create' => AAA::Web::App::CreateAPIKey->new->to_app;
	# the key protected realm
	mount '/' => builder {
		# make sure they have a Key
		enable '+AAA::Web::Middleware::Auth', scope => 'APIKey';
		# token management (behind api-key)
		mount '/token/create' => AAA::Web::App::CreateToken->new->to_app;
		# the token protected realm 
		mount '/' => builder {
			# make sure they have a Token
			enable '+AAA::Web::Middleware::Auth', scope => 'Token';
			# and finally, to the spoils ...
			Plack::App::Proxy->new( remote => 'http://0:5000/' )->to_app;
		};
	};
};