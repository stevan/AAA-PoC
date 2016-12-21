package AAA::Model::Token;

use strict;
use warnings;

our $VERSION = '0.01';

# NOTE:
# This should be a lexigraphically sortable UID
# which means it is a packed INT containing this
# data:
#
#   [[timestamp][randomness]]
# 
# due to the (monotonic) timestamp being at the 
# start we can be sure that the overall UID is
# sortable. 
#
# Since we know the time the token was issued, 
# we can easily calculate its age, which means
# we can expire it very easily.
#
# To reduce the space needed for the timestamp 
# it is possible to have a custom epoch as well. 
# 
# The randomness potion could be anything, 
# including something related to the Key.
#
# Ideally this also has the property of not 
# needing storage and being self validating 
# (minus some kind of distributed secret) 
#
# - SL

1;

__END__

=pod

=cut