#!/bin/bash

printf "Dry run: "
if [[ $DRY_RUN == true ]]; then 
  echo enabled.
else
  echo disabled.
fi

if [[ -d "${TARGET}" ]]; then
  tar -czvf "${TARGET}"
else if
  
fi

curl -X POST "${URL}"
