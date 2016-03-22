#!/bin/bash

. ~/miq-cred.sh

VM=$1
MIQ_HOST=${MIQ_HOST:-http://localhost:3000}

response=$(curl --insecure -u admin:smartvm -X POST \
	$MIQ_HOST/api/vms/$VM -H "Content-Type: application/json" -H "Accept: application/json" -d '{"action":"request_console", "resource": {"protocol":"vnc"}}')

task_url=$(echo $response | jq -r '.task_href')
task_url="${task_url}?attributes=task_results"

status=''
while [ "$status" != 'Finished' ]; do
  sleep 1
  response=$(curl --insecure -u admin:smartvm -X GET $task_url -H "Content-Type: application/json" -H "Accept: application/json")
  echo $response
  status=$(echo $response | jq -r '.state')
  echo $status
done

