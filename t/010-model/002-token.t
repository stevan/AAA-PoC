#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
	use_ok('AAA::Model::Token');
}

our $KEY = 'NjE3NDYxNDQtM0EzQS01NTU1LTQ5NDQtM0Q1MzQzNDE0QzQxOjMzM2RiNTdmYzgxNzY4NDI1ZjIzYmIxMDAwZGM5YzMyZGE1N2JmNzU=';

subtest '... basic test' => sub {

	my $t = AAA::Model::Token->new( key => $KEY );
	isa_ok($t, 'AAA::Model::Token');

	ok($t->time, '... the timestamp is there');
	ok($t->body, '... the body is there');

	my $packed = $t->pack;
	ok($packed, '... got the expected packed token');

	my $t2 = AAA::Model::Token->unpack( $packed, $KEY );
	isa_ok($t2, 'AAA::Model::Token');

	is($t->time, $t2->time, '... the times match'); 
	is($t->body, $t2->body, '... the bodies match');
};

subtest '... messy test' => sub {

	my $TIME = 1234;
	my $BODY = '1b4e098d1b8036d2c81fa63e80857808662190be';

	my $t = AAA::Model::Token->new( 
		time => $TIME, 
		body => $BODY, 
		key  => $KEY 
	);
	isa_ok($t, 'AAA::Model::Token');

	is($t->time, $TIME, '... the timestamp is there');
	is($t->body, $BODY, '... the body is there');

	my $packed = $t->pack;
	ok($packed, '... got the expected packed token');

	my $t2 = AAA::Model::Token->unpack( $packed, $KEY );
	isa_ok($t2, 'AAA::Model::Token');

	is($t->time, $t2->time, '... the times match'); 
	is($t->body, $t2->body, '... the bodies match');
};

subtest '... test errors' => sub {
	like(
		exception { AAA::Model::Token->new },
		qr/^The API key is required/,
		'... got the right error'
	);

	like(
		exception { AAA::Model::Token->new( key => $KEY, time => 1234 ) },
		qr/^Invalid args/,
		'... got the right error'
	);

	like(
		exception { AAA::Model::Token->new( key => $KEY, time => 1234, body => '0xBEEF' ) },
		qr/^Invalid token/,
		'... got the right error'
	);
};

done_testing;