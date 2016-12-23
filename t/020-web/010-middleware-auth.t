#!perl

use strict;
use warnings;

use Test::More;
use Plack::Test;

use Plack::Builder;

use HTTP::Request::Common qw[ GET ];

use AAA::Util;

use AAA::Model::APIKey;
use AAA::Model::Token;

BEGIN {
	use_ok('AAA::Web::Middleware::Auth');
}

my $APIKEY = AAA::Model::APIKey->new;
my $TOKEN  = AAA::Model::Token->new( key => $APIKEY );

test_psgi(
	builder {
		enable '+AAA::Web::Middleware::Auth', scope => 'APIKey';
		sub { [200,[],['SUCCESS']] };
	},
	sub {
        my $app = shift;

        subtest '... simple GET / test' => sub {
            my $resp = $app->(GET '/');  
            is($resp->code, 401, '... got the status (401) we expected');
            like($resp->headers->header('WWW-Authenticate'), qr/APIKey/, '... got the expected www-authenticate header');
        };

        subtest '... simple GET / test w/APIkey' => sub {
            my $resp = $app->(GET '/', (Authorization => "APIKey ".AAA::Util::encode_base64($APIKEY->pack)));  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->content, 'SUCCESS', '... got the expected content');
        };
    }
);

test_psgi(
	builder {
		enable '+AAA::Web::Middleware::Auth', scope => 'Token';
		sub { [200,[],['SUCCESS']] };
	},
	sub {
        my $app = shift;

        subtest '... simple GET / test' => sub {
            my $resp = $app->(GET '/');  
            is($resp->code, 401, '... got the status (401) we expected');
            like($resp->headers->header('WWW-Authenticate'), qr/APIKey/, '... got the expected www-authenticate header');
        };

        subtest '... simple GET / test' => sub {
            my $resp = $app->(GET '/', (Authorization => "APIKey ".AAA::Util::encode_base64($APIKEY->pack)));  
            is($resp->code, 401, '... got the status (401) we expected');
            like($resp->headers->header('WWW-Authenticate'), qr/Token/, '... got the expected www-authenticate header');
        };

        subtest '... simple GET / test w/APIkey' => sub {
            my $resp = $app->(GET '/', (Authorization => "APIKey ".AAA::Util::encode_base64($APIKEY->pack), Authorization => "Token ".AAA::Util::encode_base64($TOKEN->pack)));  
            is($resp->code, 200, '... got the status (200) we expected');
            is($resp->content, 'SUCCESS', '... got the expected content');
        };

    }
);

done_testing;