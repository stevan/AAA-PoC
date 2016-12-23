package AAA::Web::App::CreateToken;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;

use AAA::Model::Token;
use AAA::Model::APIKey;

use AAA::Web::Header::Authorization;

use Web::Machine::Resource;
our @ISA = ('Web::Machine::Resource');

sub allowed_methods { ['GET'] }

sub content_types_provided {[
	{ 'text/plain'       => \&to_text }, # default ...	
	{ 'application/json' => \&to_json },
]}

sub api_key { $_[0]->{api_key} }

sub is_authorized {
	my $self   = $_[0];
	my $header = $_[1];

	return unless $header;

	my $h = AAA::Web::Header::Authorization->new_from_header( $header );
	if ( my $creds = $h->credentials_for_scheme( 'APIKey' ) ) {
		$self->{api_key} = AAA::Model::APIKey->unpack( $creds );
		return 1;
	}
	
	return;
}

sub to_json {  
	my $self = $_[0];
	AAA::Model::Token->new( key => $self->api_key )->to_json
}

sub to_text {
	my $self = $_[0];
	AAA::Util::encode_base64( AAA::Model::Token->new( key => $self->api_key )->pack )
}

1;

__END__

=pod

=cut