# Requires OpenSSL installation.
openssl req \
  -new \
  -x509 \
  -days 36000 \
  -newkey rsa:2048 \
  -nodes \
  -config root-certificate.cnf \
  -keyout root.key \
  -out root.crt

openssl req \
  -new \
  -nodes \
  -newkey rsa:2048 \
  -keyout server.key \
  -out server.csr \
  -config server-certificate.cnf

openssl x509 \
  -req \
  -in server.csr \
  -CA root.crt \
  -CAkey root.key \
  -CAcreateserial \
  -out server.crt \
  -days 3650 \
  -sha256 \
  -extensions v3_server \
  -extfile server-certificate.cnf