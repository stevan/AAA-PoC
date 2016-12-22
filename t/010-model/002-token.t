#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
	use_ok('AAA::Model::Token');
	use_ok('AAA::Model::APIKey');	
}

our $KEY = AAA::Model::APIKey->unpack('61746144-3A3A-5555-4944-3D5343414C41:333db57fc81768425f23bb1000dc9c32da57bf75');

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
	my $BODY = '5427618426f07867dcb9179bed342a109118f9a8';

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
		qr/^Invalid args/,
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