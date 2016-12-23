package AAA::Web::Middleware::SimpleStats;

use strict;
use warnings;

our $VERSION = '0.01';

use Plack::Middleware;

our @ISA; BEGIN { @ISA = ('Plack::Middleware') }

our %STATS = (
	counter      => 0,
	path_counter => {},
);

sub call {
	my ($self, $env) = @_;

	$STATS{counter}++;
	$STATS{path_counter}->{ $env->{PATH_INFO} }++;

	return $self->app->( $env );
}

1;

__END__