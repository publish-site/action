#!/bin/bash

set -euo pipefail

TMP=$(mktemp -d)

: "${PORT:=2222}"
: "${USR:=root}"
: "${WEBDIR:=/var/www/html}"

if [[ -z "${TARGET:-}" ]]; then
  echo "Target directory not set. Exiting."
  exit 1
fi

if [[ -z "${URL:-}" ]]; then
  if [[ -z "${IP:-}" ]]; then
    echo "Neither URL nor IP found. Exiting."
    exit 1
  else
    export URL="$IP"
  fi
fi

if [[ -n "${PRIVKEY:-}" ]]; then
  echo "$PRIVKEY" > "$TMP/ssh.key"
elif [[ -n "${CERT:-}" ]]; then 
  echo "$CERT" > "$TMP/ssh.key"
else
  echo "No key or certificate found. Exiting."
  exit 1
fi

chmod 600 "$TMP/ssh.key"

echo "Removing old files..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p$PORT -i "$TMP/ssh.key" "$USR@$URL" "rm -rf $WEBDIR/*"

echo "Creating new directories..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p$PORT -i "$TMP/ssh.key" "$USR@$URL" "mkdir -p $WEBDIR/"

echo "Deploying to $URL..."
rsync -avz --delete --progress --stats --human-readable \
  --exclude=".git" \
  --exclude=".github" \
  --exclude="node_modules" \
  -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p$PORT -i $TMP/ssh.key" \
  "$TARGET"/ $USR@"$URL":$WEBDIR/

echo "Setting permissions..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p$PORT -i "$TMP/ssh.key" "$USR@$URL" "chown -R nginx:nginx $WEBDIR/"

rm -rf "$TMP"

echo "Deployment completed successfully!"