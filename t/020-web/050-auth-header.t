#!perl

use strict;
use warnings;

use Test::More;
use Plack::Test;

use AAA::Util;

BEGIN {
	use_ok('AAA::Web::Header::Authorization');
}

my $API_KEY = '61746144-3A3A-5555-4944-3D5343414C41:333db57fc81768425f23bb1000dc9c32da57bf75';
my $TOKEN   = '1234:5427618426f07867dcb9179bed342a109118f9a8';

subtest '... basic test' => sub {

	my $h = AAA::Web::Header::Authorization->new(
		credentials => {
			'apikey' => $API_KEY,
			'token'  => $TOKEN,
		}
	);
	isa_ok($h, 'AAA::Web::Header::Authorization');

	is($h->credentials_for_scheme('APIKey'), $API_KEY, '... got the expected crediential');
	is($h->credentials_for_scheme('Token'), $TOKEN, '... got the expected crediential');

};

subtest '... basic test' => sub {

	my $h = AAA::Web::Header::Authorization->new_from_env(
		{ HTTP_AUTHORIZATION => 'APIKey '.AAA::Util::encode_base64($API_KEY,'').', Token '.AAA::Util::encode_base64($TOKEN,'') }
	);
	isa_ok($h, 'AAA::Web::Header::Authorization');

	is($h->credentials_for_scheme('APIKey'), $API_KEY, '... got the expected crediential');
	is($h->credentials_for_scheme('Token'), $TOKEN, '... got the expected crediential');

};


done_testing;