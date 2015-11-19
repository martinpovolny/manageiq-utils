#!/bin/bash

MIQ_HOST=${MIQ_HOST:-http://localhost:4000/}

. ~/miq-cred.sh

curl --insecure -u admin:smartvm -X POST $MIQ_HOST/api/providers -H "Content-Type: application/json" -H "Accept: application/json" -d '{"type":"ManageIQ::Providers::Redhat::InfraManager","name":"RHEVM","hostname":"'"$RHEVM_IP"'","ipaddress":"'"$RHEVM_IP"'","credentials":[{"userid":"'"$RHEVM_USER"'","password":"'"$RHEVM_PASSWORD"'"}]}'

