#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Plack::Test;

use AAA::Util;
use AAA::Model::APIKey;

use HTTP::Request::Common qw[ GET ];

BEGIN {
	use_ok('AAA::Web::App::CreateToken');
}

my $API_KEY = AAA::Util::encode_base64('61746144-3A3A-5555-4944-3D5343414C41:333db57fc81768425f23bb1000dc9c32da57bf75', '');

test_psgi(
	AAA::Web::App::CreateToken->new->to_app, 
	sub {
        my $app = shift;

        subtest '... simple GET / test' => sub {
            my $resp = $app->(GET '/', 'Authorization' => "APIKey $API_KEY" );  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->headers->header('Content-Type'), 'text/plain', '... got the expected Content-Type');
            like($resp->content, qr/^[a-zA-Z0-9]+$/, '... got content that looks like a base64 encoded string');
        };

        subtest '... simple GET / test w/ JSON content-type' => sub {
            my $resp = $app->(GET '/', 'Authorization' => "APIKey $API_KEY", Accept => 'application/json' );  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->headers->header('Content-Type'), 'application/json', '... got the expected Content-Type');

            my $body;
            is(exception{ $body = AAA::Util->JSON->decode( $resp->content ) }, undef, '... got the body');
            like($body->{time}, qr/^\d+$/, '... got a timestamp');
            like($body->{body}, qr/^[a-zA-Z0-9]+$/, '... got a body that looks like a base64 encoded string');
        };

    }
);

done_testing;