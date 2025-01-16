#!/bin/bash
set -x
set -a
source .env
set +a

SSH_PRIV=~/.ssh/clevercloud-monstage
if [ ! -f "$SSH_PRIV" ]; then
  echo "missing private key to push, check kdbx for content"
  exit 1;
fi;

ssh -t ssh@sshgateway-clevercloud-customers.services.clever-cloud.com $OLD_CLEVER_APP_PROD_ID
