package AAA::Web::Resource::SimpleStat;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;
use AAA::Web::Middleware::SimpleStats;

use Web::Machine::Resource;
our @ISA = ('Web::Machine::Resource');

sub allowed_methods { ['GET'] }

sub content_types_provided {[
	{ 'application/json' => \&to_json },
]}

sub to_json { AAA::Util->JSON->encode( \%AAA::Web::Middleware::SimpleStats::STATS ) }

1;

__END__

=pod

=cut