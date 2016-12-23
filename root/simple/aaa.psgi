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

	# basic server stats
	mount '/admin' => builder {
		# shhh, secret
		enable 'Auth::Basic', authenticator => sub { $_[0] eq 'test' };
		# see the stats ...
		mount '/stats' => Web::Machine->new( resource => 'AAA::Web::Resource::SimpleStat' )->to_app;	
	};

	# key management ...
	mount '/api-key' => Web::Machine->new( resource => 'AAA::Web::Resource::APIKey' )->to_app;
	# the key protected realm
	mount '/' => builder {
		# make sure they have a Key
		enable '+AAA::Web::Middleware::Auth', realm => 'APIKey';
		# count some stuff ...
		enable '+AAA::Web::Middleware::SimpleStats', realm => 'APIKey';

		# token management (behind api-key)
		mount '/token' => Web::Machine->new( resource => 'AAA::Web::Resource::Token' )->to_app;
		# the token protected realm 
		mount '/' => builder {
			# make sure they have a Token
			enable '+AAA::Web::Middleware::Auth', realm => 'Token';
			# count some stuff ...
			enable '+AAA::Web::Middleware::SimpleStats', realm => 'Token';

			# and finally, to the spoils ...
			Plack::App::Proxy->new( remote => $SERVICES_REALM )->to_app;
		};
	};
};