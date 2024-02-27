#!/bin/bash
set -x

if [ ! -f "env.sh" ]; then
  echo "Usage: create.sh, must be run from ./doc/"
  exit 2
fi
source 'env.sh'


curl -H "Authorization: Bearer ${MONSTAGEDESECONDE_TOKEN}" \
     -H "Accept: application/json" \
     -X DELETE \
     -vvv \
     ${MONSTAGEDESECONDE_ENV}/api/internship_offers/test
