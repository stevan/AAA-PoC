package AAA::Web::Resource::CreateAPIKey;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;
use AAA::Model::APIKey;

use Web::Machine::Resource;
our @ISA = ('Web::Machine::Resource');

sub allowed_methods { ['GET'] }

sub content_types_provided {[
	{ 'text/plain'       => \&to_text }, # default ...	
	{ 'application/json' => \&to_json },
]}

sub to_json { AAA::Model::APIKey->new->to_json }
sub to_text { AAA::Util::encode_base64( AAA::Model::APIKey->new->pack ) }

1;

__END__

=pod

=cut