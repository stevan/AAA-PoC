# AAA - Authorization, Authentication and Accounting

This module is a proof of concept (PoC) hack of a AAA framework, it is 
meant to be a source for discussion, *nothing more*. 

It is meant to communicate a particular concept of how an AAA framework 
*might* work, and really only the concepts illustrated here should be 
discussed, not the specific code. 

# CAVEAT

This is **not** meant to be production ready in any way, shape, or form.
Did I mention that before? Cool, we are good, you may proceed.

## Model

For the purposes of this demo, here is a description of the 
data models used in this PoC.

### Keys

Keys are the base level of entry, they are a tuple of an `id`, 
in the form of a stringified UUID, and a `key` which is some kind 
of digital signature, the simplest form being a SHA of the `id` + 
some secret value, the more complex form being a packet of 
encrypted data. 

Keys have no expiration, but they can be revoked. Though the 
process of revoking them is not (yet) specified.

### Tokens

Tokens are used for all subsequent entry layers, they are also a
tuple, but containing different elements. The first item is a 
`timestamp` of when the token was issued, and the second item is
again a digital signature, the simplest form being a SHA of the 
`timestamp` + some secret value, the more complex form being a 
packet of encrypted data. (Yes, if your brain said "HMAC", then you 
are smellin' what I am cookin').

## AAA

This is a rough overview of how the three A layers interact and 
how they are implemented.

### Authentication

This part of the trio is done via a combination of the AAA::Model::* 
classes and the AAA::Web::Resource::* classes, which provide a means
of generating and validating keys and tokens. 

### Authorization

This part of the trio is done primarily via AAA::Web::Middleware::Auth
which, given a `scope` of either `APIKey` or `Token`, will manage the 
protected realms. 

### Accounting

Currently this part of the trio is sketched out kind of poorly. The 
accounting itself is done via AAA::Web::Middleware::SimpleStats and the 
reporting of those stats is done via AAA::Web::Resource::SimpleStat 
resource. 

## Examples

### Simple Example

First start the services.

``` 
  plackup -I lib/ -p 3000 root/services.psgi 
```

Next start up the AAA proxy server making sure to let it know where
to find the services.

```
  export SERVICES_REALM="http://0:3000"; 
  plackup -I lib/ -p 5000 root/simple/aaa.psgi 
```

Now poke it with a client:

```
  export API_KEY=$(curl -v http://0:5000/api-key)
  export TOKEN=$(curl -v http://0:5000/token -H "Authorization: APIKey $API_KEY")

  curl -v http://0:5000/ -H "Authorization: APIKey $API_KEY" -H "Authorization: Token $TOKEN"
```

### Complex Example

First start the services.

``` 
  plackup -I lib/ -p 3000 root/services.psgi 
```

Next start up the AAA proxy server for the Token realm, connecting it with the services.

```
  export SERVICES_REALM="http://0:3000"; 
  plackup -I lib/ -p 4000 root/complex/token-realm.psgi 
```

Then start up the AAA proxy server for the APIKey realm, connecting it with the Token realm.

```
  export TOKEN_REALM="http://0:4000"; 
  plackup -I lib/ -p 5000 root/complex/api-key-realm.psgi 
```

Now poke it with a client:

```
  export API_KEY=$(curl -v http://0:5000/api-key)
  export TOKEN=$(curl -v http://0:5000/token -H "Authorization: APIKey $API_KEY")

  curl -v http://0:5000/ -H "Authorization: APIKey $API_KEY" -H "Authorization: Token $TOKEN"
```