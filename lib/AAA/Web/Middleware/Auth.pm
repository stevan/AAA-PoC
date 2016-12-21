package AAA::Web::Middleware::Auth;

use strict;
use warnings;

use AAA::Model::APIKey;
use AAA::Model::Token;

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw[ scope ];

sub prepare_app {
    my $self = $_[0];

    die 'You must specify a scope for the Auth middleware to operate in'
        unless $self->scope;

    # caninical form 
    $self->scope( lc $self->scope );
}

sub call {
    my($self, $env) = @_;

    my $auth_header = $env->{HTTP_AUTHORIZATION}
        or return $self->unauthorized;

    my @auth = split /\,\s*/ => $auth_header;

    if ( $self->scope eq 'key' ) {
        my ($key_header) = grep /^Basic\s+/i, @auth;

        return $self->unauthorized('Unable to find auth header for `key` scope')
            unless $key_header;

        my ($key) = ($key_header =~ /^Basic (.*)$/i);

        return $self->unauthorized('Unable to find the key in the auth header, in `key` scope')
            unless $key;

        return $self->app->($env)
            if AAA::Model::APIKey->validate($key);
    }
    elsif ( $self->scope eq 'token' ) {
        my ($key_header)   = grep /^Basic\s+/i, @auth;
        my ($token_header) = grep /^Token\s+/i, @auth;

        return $self->unauthorized('Unable to find auth header for `key` scope in `token` scope')
            unless $key_header;

        return $self->unauthorized('Unable to find auth header for `token` scope')
            unless $token_header;            

        my ($key)   = ($key_header   =~ /^Basic (.*)$/i);
        my ($token) = ($token_header =~ /^Token (.*)$/i);

        return $self->unauthorized('Unable to find the key in the auth header, in `token` scope')
            unless $key;

        return $self->unauthorized('Unable to find the token in the auth header, in `token` scope')
            unless $token;            

        return $self->app->($env)
            if AAA::Model::Token->validate($token, $key);
    }

    return $self->unauthorized;
}

sub unauthorized {
    my $self = shift;
    my $msg  = shift;
    $msg = ": $msg" if $msg;
    my $body = 'Authorization required'.$msg;
    return [
        401,
        [ 'Content-Type' => 'text/plain',
          'Content-Length' => length $body,
          'WWW-Authenticate' => 'Basic realm="' . $self->scope . '"' ],
        [ $body ],
    ];
}

1;

__END__

=pod

=cut