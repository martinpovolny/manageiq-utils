#!/bin/bash

MIQ_HOST=${MIQ_HOST:-http://localhost:4000/}

. ~/miq-cred.sh

curl --insecure -u admin:smartvm -X POST $MIQ_HOST/api/providers -H "Content-Type: application/json" -H "Accept: application/json" -d \
'{"type":"ManageIQ::Providers::Softlayer::CloudManager",
  "name":"SoftLayer",
  "provider_region":"'"$SL_REG"'",
  "credentials":[{"userid":"'"$SL_USER"'","password":"'"$SL_PASSWORD"'"}]}'
