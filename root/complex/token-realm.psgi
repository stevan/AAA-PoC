#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

use Plack::App::Proxy;

use Web::Machine;

use AAA::Web::App::CreateToken;
use AAA::Web::Middleware::Auth;

my $SERVICES_REALM = $ENV{'SERVICES_REALM'} || die 'You must specify a `SERVICES_REALM` env variable';

builder {
	# token management (should be behind an api-key)
	mount '/token/create' => Web::Machine->new( resource => 'AAA::Web::App::CreateToken' )->to_app;
	# the token protected realm 
	mount '/' => builder {
		# make sure they have a Token
		enable '+AAA::Web::Middleware::Auth', scope => 'Token';
		# and finally, to the spoils ...
		Plack::App::Proxy->new( remote => $SERVICES_REALM )->to_app;
	};
};