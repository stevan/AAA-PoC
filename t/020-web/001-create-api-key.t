#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Plack::Test;

use AAA::Util;
use Web::Machine;

use HTTP::Request::Common qw[ GET ];

BEGIN {
	use_ok('AAA::Web::App::CreateAPIKey');
}

test_psgi(
	Web::Machine->new( resource => 'AAA::Web::App::CreateAPIKey' )->to_app, 
	sub {
        my $app = shift;

        subtest '... simple GET / test' => sub {
            my $resp = $app->(GET '/');  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->headers->header('Content-Type'), 'text/plain', '... got the expected Content-Type');
            like($resp->content, qr/^[a-zA-Z0-9]+\=$/, '... got content that looks like a base64 encoded string');
        };

        subtest '... simple GET / test w/ JSON content-type' => sub {
            my $resp = $app->(GET '/', Accept => 'application/json' );  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->headers->header('Content-Type'), 'application/json', '... got the expected Content-Type');

            my $body;
            is(exception{ $body = AAA::Util->JSON->decode( $resp->content ) }, undef, '... got the body');
            like($body->{id}, qr/^[A-F0-9]{8}\-[A-F0-9]{4}\-[A-F0-9]{4}\-[A-F0-9]{4}\-[A-F0-9]{12}$/, '... got an id that looks like a UUID');
            like($body->{key}, qr/^[a-zA-Z0-9]+$/, '... got a key that looks like a base64 encoded string');
        };

    }
);

done_testing;