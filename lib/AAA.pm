package AAA;

use strict;
use warnings;

use JSON::MaybeXS;

our $JSON = JSON::MaybeXS->new->utf8->pretty->canonical;

1;

__END__