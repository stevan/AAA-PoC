#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

use Plack::App::Proxy;

use Web::Machine;

use AAA::Web::Resource::APIKey;
use AAA::Web::Resource::Token;

use AAA::Web::Middleware::Auth;

my $SERVICES_REALM = $ENV{'SERVICES_REALM'} || die 'You must specify a `SERVICES_REALM` env variable';

builder {
	# key management ...
	mount '/api-key' => Web::Machine->new( resource => 'AAA::Web::Resource::APIKey' )->to_app;
	# the key protected realm
	mount '/' => builder {
		# make sure they have a Key
		enable '+AAA::Web::Middleware::Auth', scope => 'APIKey';
		# token management (behind api-key)
		mount '/token' => Web::Machine->new( resource => 'AAA::Web::Resource::Token' )->to_app;
		# the token protected realm 
		mount '/' => builder {
			# make sure they have a Token
			enable '+AAA::Web::Middleware::Auth', scope => 'Token';
			# and finally, to the spoils ...
			Plack::App::Proxy->new( remote => $SERVICES_REALM )->to_app;
		};
	};
};