#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

builder {
	sub { 
		my $env = $_[0];
		[ 200, [], [ 'Hello World (' . $env->{PATH_INFO} . ')' ] ] 
	}
};