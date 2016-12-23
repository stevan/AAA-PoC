# AAA - Authorization, Authentication and Accounting

This module is a proof of concept hack of a AAA framework, it is 
meant to be a source for discussion, nothing more.

## Simple Example

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

## Complex Example

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