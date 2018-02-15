SUBJPREFIX ?= /C=US/ST=CA/O=Blockchain/CN=
RSALEN ?= 1024

all: ca/ca.crt server1.p12 client1.p12 client2.p12

ca/ca.crt:
	mkdir -p ca/private
	mkdir -p ca/newcerts
	chmod 700 ca/private
	touch ca/index.txt
	openssl req -new -nodes -newkey rsa:$(RSALEN) -keyout ca/private/ca.key -out ca/careq.csr -config openssl.cnf -subj "$(SUBJPREFIX)CA"
	openssl ca -batch -create_serial -out $@ -days 3650 -keyfile ca/private/ca.key -selfsign -config openssl.cnf -infiles ca/careq.csr

%.key:
	openssl genrsa -out $@ $(RSALEN)

%.csr: %.key
	openssl req -new -nodes -key $< -out $@ -subj "$(SUBJPREFIX)$*"

server%.crt: server%.csr ca/ca.crt
	openssl ca -batch -config openssl.cnf -in $< -out $@

%.crt: %.csr ca/ca.crt
	openssl ca -batch -config openssl.cnf -extensions ssl_client -in $< -out $@

%.p12: %.crt ca/ca.crt
	openssl pkcs12 -export -passout pass:123 -in $< -inkey $*.key -CAfile ca/ca.crt -name $* -out $@


clean:
	rm -rf ca/ *.p12 *.key *.crt

.PHONY: clean
.PRECIOUS: %.key %.crt %.p12
