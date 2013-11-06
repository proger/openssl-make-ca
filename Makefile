HOST ?= example.com
SUBJ ?= /C=AU/ST=Some-State/L=Springfield/O=Internet Widgits/CN=$(HOST)

ssl:
	env SUBJ="$(SUBJ)" ./create_ca
	env SUBJ="$(SUBJ)" ./create_key_csr server
	env SUBJ="$(SUBJ)" ./create_key_csr client
	# sign csrs with a CA
	openssl ca -batch -config openssl.cnf -in server/server.csr -out server/server.pem
	openssl ca -batch -config openssl.cnf -extensions ssl_client -in client/client.csr -out client/client.pem

clean:
	git clean -dxf
