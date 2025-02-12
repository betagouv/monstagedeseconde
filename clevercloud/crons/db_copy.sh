#!/bin/bash -l
#see: https://www.clever-cloud.com/doc/tools/crons/
set -x

if [[ "$INSTANCE_NUMBER" != "0" ]]; then
    echo "Instance number is ${INSTANCE_NUMBER}. Stop here."
    exit 0
fi

cd ${APP_HOME}
mkdir -p storage/tmp
chmod 777 storage/tmp
bundle exec rails sys:dl_upl_prod_sql
