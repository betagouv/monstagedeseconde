#!/bin/bash
set -x

if [ ! -f "env.sh" ]; then
  echo "Usage: index.sh, must be run from ./doc/"
  exit 2
fi
source 'env.sh'

INPUT_FILE="input/internship_offers/index.json"

curl -H "Authorization: Bearer ${MONSTAGEDESECONDE_TOKEN}" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X GET \
     -d @$INPUT_FILE \
     -vvv \
     ${MONSTAGEDESECONDE_ENV}/api/internship_offers

