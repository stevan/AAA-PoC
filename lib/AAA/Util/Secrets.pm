package AAA::Util::Secrets;

use strict;
use warnings;

use Path::Tiny  ();
use Digest::SHA ();

our $VERSION = '0.01';

sub get_share_dir {
	my $share = Path::Tiny::path(__FILE__);
	   $share = $share->parent 
		   until $share->is_dir 
		      && $share->basename eq 'lib';
	return $share->parent->child('share');
}

sub get_secret_file { get_share_dir()->child('secret') }
sub get_secret      { get_secret_file()->slurp         }

sub get_digest_of {
	#use Data::Dumper;
	#Carp::cluck( Dumper \@_ );
	Digest::SHA::sha1_hex( join '' => @_, get_secret() );
}

1;

__END__