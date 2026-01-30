#!/bin/bash

printf "Dry run: "

if [[ $DRY_RUN == true ]]; then 
  echo enabled.
  agent="DRY"
else
  echo disabled.
  agent="Actions"
fi

if [[ -d "${TARGET}" ]]; then
  tar -czvf upload.tar.gz "${TARGET}"
#else if
  
fi

base64 upload.tar.gz > encoded

curl -T 'encoded' -A "$agent" "${URL}" -vv
