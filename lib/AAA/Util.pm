package AAA::Util;

use strict;
use warnings;

our $VERSION = '0.01';

use JSON::MaybeXS;
use MIME::Base64 ();

use constant JSON => JSON::MaybeXS->new->utf8->pretty->canonical;

sub encode_base64 { MIME::Base64::encode_base64( $_[0], '' ) }
sub decode_base64 { MIME::Base64::decode_base64( $_[0] )     }

1;

__END__