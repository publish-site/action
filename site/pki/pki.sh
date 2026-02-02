#!/bin/bash

echo Certificates
fqdn="api.localhost.rvid.eu"
mail="."

helpcmd () {
    echo "Usage: ./pki.sh -s api.localhost.rvid.eu"
}

while getopts ":n:v" opt; do
  case $opt in
    s) fqdn="$OPTARG" ;;
    m) mail="$OPTARG" ;;
    h) helpcmd ;;
  esac
done

echo "Generating CA certificates."

mkdir -p /dev/shm/mtls
chmod 700 /dev/shm/mtls

openssl genrsa -out /dev/shm/mtls/CA.key 4096
openssl req -new -x509 -key /dev/shm/mtls/CA.key -out CA.pem \
    -subj "/CN=${fqdn}/emailAddress=${mail}" \
    -sha256

echo "Generating client certificates (mTLS)"

openssl req -newkey rsa:4096 -nodes -keyout client.key -out client.csr -subj "/CN=actions" # Client key and csr
openssl x509 -req -in client.csr -CA CA.pem -CAkey /dev/shm/mtls/CA.key -out client.pem -sha256 # Client certificate

echo Cleaning up