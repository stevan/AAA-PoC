package AAA::Util;

use strict;
use warnings;

our $VERSION = '0.01';

use JSON::MaybeXS;

use constant JSON => JSON::MaybeXS->new->utf8->pretty->canonical;

1;

__END__