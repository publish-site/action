#!/bin/bash

TMP=$(mktemp -d)
printf "Dry run: "

if [[ $DRY_RUN == true ]]; then 
  echo enabled.
  agent="DRY"
else
  echo disabled.
  agent="Actions"
fi

if [[ -n "${TARGET}" ]]; then
  tar -czvf "$TMP/upload.tar.gz" -C "${TARGET}" .
else
  echo "Target directory not set. Exiting"
  exit 1
fi

if [[ -n "$PRIVKEY" ]]; then
  base64 -d <<< "$PRIVKEY" > "$TMP/client.key"
else
  echo "Private key (privkey input) not set. Exiting"
  exit 1
fi

if [[ -n "$CERT" ]]; then
  base64 -d <<< "$PRIVKEY" > "$TMP/client.key"
else
  echo "Certificate (cert input) not set. Exiting"
  exit 1
fi

base64 "$TMP/upload.tar.gz" | curl -d @- -A "$agent" "${URL}" -vv --cert /tmp/client.key
