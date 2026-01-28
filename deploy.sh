#!/bin/bash

printf "Dry run: "
if [[ $DRY_RUN == true ]]; then 
  echo enabled.
else
  echo disabled.
fi
