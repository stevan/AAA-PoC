package AAA::Web::Middleware::SimpleStats;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Model::Accounting::Counter;

use Plack::Middleware;

our @ISA; BEGIN { @ISA = ('Plack::Middleware') }

our %REALMS;

sub realm { $_[0]->{realm} = $_[1] if $_[1]; $_[0]->{realm} }

sub prepare_app {
	my $self = $_[0];
    die 'You must specify a realm from which to gather stats'
        unless $self->realm;

    $REALMS{ $self->realm } = AAA::Model::Accounting::Counter->new;
}

sub call {
	my ($self, $env) = @_;
	$REALMS{ $self->realm }->track( $env );
	return $self->app->( $env );
}

1;

__END__