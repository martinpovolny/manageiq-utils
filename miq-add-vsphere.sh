#!/bin/bash

MIQ_HOST=${MIQ_HOST:-http://localhost:4000/}

. ~/miq-cred.sh

curl --insecure -u admin:smartvm -X POST $MIQ_HOST/api/providers -H "Content-Type: application/json" -H "Accept: application/json" -d '{"type":"ManageIQ::Providers::Vmware::InfraManager","name":"VSP","hostname":"'"$VSP_IP"'","ipaddress":"'"$VSP_IP"'","credentials":[{"userid":"'"$VSP_USER"'","password":"'"$VSP_PASSWORD"'"}]}'

