#!/bin/bash

set -euo pipefail

TMP=$(mktemp -d)

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
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p2222 -i "$TMP/ssh.key" root@"$URL" "rm -rf /var/www/html/*"

echo "Creating new directories..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p2222 -i "$TMP/ssh.key" root@"$URL" "mkdir -p /var/www/html/"

echo "Deploying to $URL..."
rsync -avz --delete --progress --stats --human-readable \
  --exclude=".git" \
  --exclude=".github" \
  --exclude="node_modules" \
  -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p2222 -i $TMP/ssh.key" \
  "$TARGET"/ root@"$URL":/var/www/html/

echo "Setting permissions..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p2222 -i "$TMP/ssh.key" root@"$URL" "chown -R www-data:www-data /var/www/html/"

rm -rf "$TMP"

echo "Deployment completed successfully!"