package AAA::Web::Middleware::Auth;

use strict;
use warnings;

our $VERSION = '0.01';

use AAA::Util;
use AAA::Model::APIKey;
use AAA::Model::Token;

use AAA::Web::Header::Authorization;

use Plack::Middleware;

our @ISA; BEGIN { @ISA = ('Plack::Middleware') }

sub scope { $_[0]->{scope} = $_[1] if $_[1]; $_[0]->{scope} }

sub prepare_app {
    my $self = $_[0];

    die 'You must specify a scope for the Auth middleware to operate in'
        unless $self->scope;

    # caninical form 
    $self->scope( lc $self->scope );

    die 'You must specify a valid scope for the Auth middleware to operate in (apikey or token) not (' . $self->scope . ')'
        unless $self->scope eq 'apikey' 
            || $self->scope eq 'token';
}

sub call {
    my ($self, $env) = @_;

    return $self->unauthorized(APIKey => 'No authorization header found')
        unless exists $env->{HTTP_AUTHORIZATION};

    my $auth_header = AAA::Web::Header::Authorization->new_from_env( $env );

    #use Data::Dumper;
    #warn Dumper $auth_header;

    if ( $self->scope eq 'apikey' ) {
        my $key = $auth_header->credentials_for_scheme( 'APIKey' );

        return $self->unauthorized(APIKey => 'Unable to find the key in the auth header, in `key` scope')
            unless $key;

        if ( AAA::Model::APIKey->validate( $key ) ) {
            $env->{'aaa.api_key'} = AAA::Model::APIKey->unpack( $key );
            return $self->app->($env);
        }
        else {
            return $self->unauthorized(APIKey => 'Unable to validate the API key');
        }
    }
    elsif ( $self->scope eq 'token' ) {
        my $key   = $auth_header->credentials_for_scheme( 'APIKey' );
        my $token = $auth_header->credentials_for_scheme( 'Token' );

        return $self->unauthorized(Token => 'Unable to find the key in the auth header, in `token` scope')
            unless $key;

        return $self->unauthorized(Token => 'Unable to find the token in the auth header, in `token` scope')
            unless $token;     

        if ( AAA::Model::APIKey->validate( $key ) ) {
            $env->{'aaa.api_key'} = AAA::Model::APIKey->unpack( $key );
            if ( AAA::Model::Token->validate( $token, $env->{'aaa.api_key'} ) ) {
                $env->{'aaa.token'} = AAA::Model::Token->unpack( $token, $env->{'aaa.api_key'} );
                return $self->app->($env);
            }
            else {
                return $self->unauthorized(Token => 'Unable to validate the Token');
            }
        }
        else {
            return $self->unauthorized(Token => 'Unable to validate the API key for the Token');
        }
    }

    die 'This should never happen';
}

sub unauthorized {
    my $self = shift;
    my $type = shift;
    my $msg  = shift;
    my $body = "Authorization required: $msg";
    return [
        401,
        [ 
            'Content-Type'     => 'text/plain',
            'Content-Length'   => length $body,
            'WWW-Authenticate' => $type . ' realm="The Great and Powerful Realm of The ' . ucfirst($self->scope) . '"' 
        ],
        [ $body ],
    ];
}

1;

__END__

=pod

=cut