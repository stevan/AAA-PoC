package AAA::Web::Middleware::Auth;

use strict;
use warnings;

our $VERSION = '0.01';

use MIME::Base64 ();

use AAA::Model::APIKey;
use AAA::Model::Token;

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

    my $auth_header = $env->{HTTP_AUTHORIZATION}
        or return $self->unauthorized(APIKey => 'No authorization header found');

    my @auth = split /\,\s*/ => $auth_header;

    if ( $self->scope eq 'apikey' ) {
        my ($key_header) = grep /^APIKey\s+/i, @auth;

        return $self->unauthorized(APIKey => 'Unable to find auth header for `key` scope')
            unless $key_header;

        my ($key) = ($key_header =~ /^APIKey (.*)$/i);

        $key = MIME::Base64::decode_base64( $key );

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
        my ($key_header)   = grep /^APIKey\s+/i, @auth;
        my ($token_header) = grep /^Token\s+/i, @auth;

        #warn "KEY_HEADER: $key_header";
        #warn "TOKEN_HEADER: $token_header";

        return $self->unauthorized(Token => 'Unable to find auth header for `key` scope in `token` scope')
            unless $key_header;

        return $self->unauthorized(Token => 'Unable to find auth header for `token` scope')
            unless $token_header;            

        my ($key)   = ($key_header   =~ /^APIKey (.*)$/i);
        my ($token) = ($token_header =~ /^Token (.*)$/i);

        $key   = MIME::Base64::decode_base64( $key );
        $token = MIME::Base64::decode_base64( $token );

        #warn "KEY: $key";
        #warn "TOKEN: $token";

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