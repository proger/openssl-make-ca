HOST ?= example.com
SUBJ ?= /C=AU/ST=Some-State/L=Springfield/O=Internet Widgits/CN=$(HOST)

ssl:
	env SUBJ="$(SUBJ)" ./create_ca
	env SUBJ="$(SUBJ)" ./create_key_csr server
	env SUBJ="$(SUBJ)" ./create_key_csr client
	# sign csrs with a CA
	openssl ca -batch -config openssl.cnf -in server.csr -out server.pem
	openssl ca -batch -config openssl.cnf -extensions ssl_client -in client.csr -out client.pem
	# export to p12 with password 123
	openssl pkcs12 -export -passout pass:123 -in server.pem -inkey server.key -out server.p12 -name "server certificate"
	openssl pkcs12 -export -passout pass:123 -in client.pem -inkey client.key -out client.p12 -CAfile ca/ca.crt -name "client certificate"
	openssl pkcs12 -export -passout pass:123 -in ca/ca.crt -inkey ca/private/ca.key -out ca/private/ca.p12 -name "root CA"

NAME ?= star

star-ca:
	env SUBJ="/C=AU/ST=Some-State/L=Springfield/O=Internet Widgits/CN=*.$(HOST)" ./create_ca

star:
	env SUBJ="/C=AU/ST=Some-State/L=Springfield/O=Internet Widgits/CN=*.$(HOST)" ./create_key_csr $(NAME)
	# sign csrs with a CA
	openssl ca -batch -config openssl.cnf -in $(NAME).csr -out $(NAME).crt

clean:
	git clean -dxf
