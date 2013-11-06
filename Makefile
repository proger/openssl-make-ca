HOST ?= example.com
SUBJ ?= /C=AU/ST=Some-State/L=Springfield/O=Internet Widgits/CN=$(HOST)

ssl:
	env SUBJ="$(SUBJ)" ./create_ca
	env SUBJ="$(SUBJ)" ./create_key_csr server
	env SUBJ="$(SUBJ)" ./create_key_csr client
	# sign csrs with a CA
	openssl ca -batch -config openssl.cnf -in server/server.csr -out server/server.pem
	openssl ca -batch -config openssl.cnf -extensions ssl_client -in client/client.csr -out client/client.pem
	# export to p12 with password 123
	openssl pkcs12 -export -passout pass:123 -in server/server.pem -inkey server/private/server.key -out server/private/server.p12 -name "server certificate"
	openssl pkcs12 -export -passout pass:123 -in client/client.pem -inkey client/private/client.key -out client/private/client.p12 -name "client certificate"

clean:
	git clean -dxf
