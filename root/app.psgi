#!perl

use strict;
use warnings;

use Plack;
use Plack::Builder;

builder {
	sub { [200, [], ['Hello World']] }
};