#!/bin/bash -l
#see: https://www.clever-cloud.com/doc/tools/crons/

if [[ "$INSTANCE_NUMBER" != "0" ]]; then
    echo "Instance number is ${INSTANCE_NUMBER}. Stop here."
    exit 0
fi

cd ${APP_HOME}

bundle exec rails runner "Services::CegidCrawler.new.fetch_and_create_offers_decathlon" 