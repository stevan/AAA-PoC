#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
	use_ok('AAA::Model::APIKey');
}

subtest '... basic test' => sub {
	my $key = AAA::Model::APIKey->new;
	isa_ok($key, 'AAA::Model::APIKey');

	ok($key->id, '... got an expected ID'); 
	ok($key->key, '... got an expected key');

	my $packed = $key->pack;
	ok($packed, '... got the expected packed key');

	my $key2 = AAA::Model::APIKey->unpack( $packed );
	isa_ok($key2, 'AAA::Model::APIKey');

	is($key->id, $key2->id, '... the IDs match'); 
	is($key->key, $key2->key, '... the keys match');
};

subtest '... basic test w/ ID' => sub {
	my $UUID = Data::UUID->new;
	my $id   = $UUID->to_string( $UUID );

	my $key = AAA::Model::APIKey->new( id => $id );
	isa_ok($key, 'AAA::Model::APIKey');

	is($key->id, $id, '... got an expected ID'); 
	ok($key->key, '... got an expected key');

	my $packed = $key->pack;
	ok($packed, '... got the expected packed key');

	my $key2 = AAA::Model::APIKey->unpack( $packed );
	isa_ok($key2, 'AAA::Model::APIKey');

	is($key->id, $key2->id, '... the IDs match'); 
	is($id, $key2->id, '... the IDs match'); 
	is($key->key, $key2->key, '... the keys match');
};

subtest '... test errors' => sub {
	like(
		exception { AAA::Model::APIKey->new( id => 'foo', key => '0xF00' ) },
		qr/^Invalid key/,
		'... got the right error'
	);
};

done_testing;