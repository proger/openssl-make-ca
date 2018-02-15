## OpenSSL Self-Signed CA with make(1)

Have your own CA and client/server certs in a jiffy for 10 years.

Usage:

```console
$ make all          # generate a CA and a couple of certs

# or if you want to specify the names of certs (file basename serves as CN as well)
$ make laptop.p12    # if not prefixed with "server", enables -extension ssl_client
$ make server42.p12 

# note that p12's have the password "123"
```
