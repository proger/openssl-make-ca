OPENSSL ?= /usr/local/opt/openssl/bin/openssl
SUBJPREFIX ?= /C=US/ST=CA/O=Blockchain/CN=
RSALEN ?= 1024
CLIENT_EXTENSIONS ?= -extensions ssl_client
EXTENSIONS ?= -extensions subjectAltName_env
export ALT_NAMES

all: ca/ca.crt server1.p12 client1.p12 client2.p12

ca/ca.crt:
	mkdir -p ca/private
	mkdir -p ca/newcerts
	chmod 700 ca/private
	touch ca/index.txt
	$(OPENSSL) req -new -nodes -newkey rsa:$(RSALEN) -keyout ca/private/ca.key -out ca/careq.csr -config openssl.cnf -subj "$(SUBJPREFIX)CA"
	$(OPENSSL) ca -batch -create_serial -out $@ -days 3650 -keyfile ca/private/ca.key -selfsign -config openssl.cnf -infiles ca/careq.csr

%.key:
	$(OPENSSL) genrsa -out $@ $(RSALEN)

%.csr: %.key
	$(OPENSSL) req -new -nodes -key $< -out $@ -subj "$(SUBJPREFIX)$*" $(EXTENSIONS) -config openssl.cnf

server%.crt: server%.csr ca/ca.crt
	$(OPENSSL) ca -batch -config openssl.cnf $(EXTENSIONS) -in $< -out $@
	$(OPENSSL) x509 -in $@ -out $@

%.crt: %.csr ca/ca.crt
	$(OPENSSL) ca -batch -config openssl.cnf $(EXTENSIONS) $(CLIENT_EXTENSIONS) -in $< -out $@
	$(OPENSSL) x509 -in $@ -out $@

%.p12: %.crt ca/ca.crt
	$(OPENSSL) pkcs12 -export -passout pass:123 -in $< -inkey $*.key -CAfile ca/ca.crt -name $* -out $@


clean:
	rm -rf ca/ *.p12 *.key *.crt

.PHONY: clean
.PRECIOUS: %.key %.crt server%.crt %.p12
