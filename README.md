## OpenSSL Self-Signed CA with make(1)

Have your own CA and client/server certs in a jiffy for 10 years.

Usage:

```console
## generate a CA and a couple of certs
$ make all

## you can specify arbitrary crt or p12 targets
## file basename serves as CN
$ make laptop.p12    # if not prefixed with "server", enables -extension ssl_client
$ make server42.p12 

## note that p12 exports have the password "123"
```
