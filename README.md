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

## OpenVPN server-to-clients

Contains sample Mikrotik RouterOS-compatible OpenVPN configs.

```bash
sudo openvpn openvpn-server1.conf

# use --redirect-gateway if you want default routes to be reset
sudo openvpn --config openvpn-client1.conf --redirect-gateway autolocal
```

## HTTPS with SNI

```bash
make localhost.p12 ALT_NAMES=DNS:localhost,DNS:www.localhost,DNS:mx.localhost,DNS:xmpp.localhost CLIENT_EXTENSIONS=
```

```console
~/openssl-make-ca% openssl x509 -in localhost.crt -text | grep -A1 Alternative
  X509v3 Subject Alternative Name: 
      DNS:localhost, DNS:www.localhost, DNS:mx.localhost, DNS:xmpp.localhost
```

To test you can start a local https server (needs Erlang installed):

```bash
erl -boot start_sasl -eval 'compile:file(httpsd), code:load_file(httpsd), httpsd:start().' -certfile localhost.crt  -keyfile localhost.key -cacertfile ca/ca.crt

curl -v --cacert ca/ca.crt https://localhost:8080/

curl -v -4 --resolve www.localhost:8080:127.0.0.1 --cacert ca/ca.crt https://www.localhost:8080/
```
