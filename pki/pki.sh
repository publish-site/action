#!/bin/bash

server="localhost"
client="actions"
org="publish-action"

while getopts "on:" opt; do
  case $opt in
    s) server="$OPTARG" ;;
    c) client="$OPTARG" ;;
    o) org="$OPTARG" ;;
    *) exit 1 ;;
  esac
done

echo Generating certificate authority
openssl genpkey -algorithm RSA -out ca.key -aes256
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt

echo Generating server certificate
openssl genpkey -algorithm RSA -out server.key -aes256
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -sha256

echo generating client 
openssl genpkey -algorithm RSA -out client.key -aes256
openssl req -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -sha256