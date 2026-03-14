#!/bin/bash

set -euo pipefail

TMP=$(mktemp -d)

if [[ ! -n "${TARGET}" ]]; then
  echo "Target directory not set. Exiting"
  exit 1
fi

if [[ ! -n "$URL" ]]; then
  if [[ ! -n "$IP" ]]; then
    echo "No URL or IP found. Exiting"
    exit 1
  else
    export URL="$IP"
  fi
fi

if [[ -n "$PRIVKEY" ]]; then
  echo "$PRIVKEY" > "$TMP/ssh.key"
elif [[ -n "$CERT" ]]; then 
  echo "$CERT" > "$TMP/ssh.key"
else
  echo "No key found. Exiting"
  exit 1
fi

echo "Deploying to $URL..."
cd "$TARGET"
ssh root@$URL -i $TMP/ssh.key "rm -rf /var/www/html/"
ssh root@$URL -i $TMP/ssh.key "mkdir -p /var/www/html/"
rsync -avz --delete --progress --human-readable \
  --exclude=".git" \
  --exclude=".github" \
  --exclude="node_modules" \
  -e "ssh -i $TMP/ssh.key -p 2222" \
  . root@$URL:/var/www/html/
ssh root@$URL -i $TMP/ssh.key "chown -R www-data:www-data /var/www/html/"