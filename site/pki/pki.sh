#!/bin/bash

fqdn="api.localhost.rvid.eu"
mail="."
PWD=$(pwd)
TMP=$(mktemp -d)
cd "$TMP"

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

echo -e "\033[92mGenerating CA certificates.\033[0m"

mkdir -p /dev/shm/mtls
chmod 700 /dev/shm/mtls

openssl genrsa -out /dev/shm/mtls/CA.key 4096
openssl req -new -x509 -key /dev/shm/mtls/CA.key -out CA.pem \
    -subj "/CN=${fqdn}/emailAddress=${mail}" \
    -sha256

echo -e "\033[92mGenerating client certificates (mTLS)\033[0m"

openssl req -newkey rsa:4096 -nodes -keyout client.key -out client.csr -subj "/CN=actions" # Client key and csr
openssl x509 -req -in client.csr -CA CA.pem -CAkey /dev/shm/mtls/CA.key -out client.pem -sha256 # Client certificate

echo -e "\033[32mServer Configuration\n\033[92mCLIENT_CA\033[0m:"
base64 "CA.pem" -w 0
printf "\n\n\n"

echo -e "\033[32mWorkflow Configuration\n\033[92mprivkey \033[0m(add as action SECRET!):"
base64 client.key -w 0
printf "\n\n"
echo -e "\033[92mcert \033[0m(add as action SECRET):"
base64 client.pem -w 0
printf "\n\n\n"

cd "$PWD"
rm -rf /dev/shm/mtls 
echo -e "\033[32mCertificates can be directly mounted and are located at \033[0m$TMP"
