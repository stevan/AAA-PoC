#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

use Plack::App::Proxy;

use AAA::Web::App::CreateAPIKey;
use AAA::Web::Middleware::Auth;

my $TOKEN_REALM = $ENV{'TOKEN_REALM'} || die 'You must specify a `TOKEN_REALM` env variable';

builder {
	# key management ...
	mount '/api-key/create' => AAA::Web::App::CreateAPIKey->new->to_app;
	# the key protected realm
	mount '/' => builder {
		# make sure they have a Key
		enable '+AAA::Web::Middleware::Auth', scope => 'APIKey';
		# now forward them on ...
		Plack::App::Proxy->new( remote => $TOKEN_REALM )->to_app
	};
};