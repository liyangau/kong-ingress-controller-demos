#!/usr/bin/env bash

set -e

if [ "$(kubectl get deployment httpbin -o=jsonpath='{.status.availableReplicas},{.status.readyReplicas},{.status.replicas},{.status.updatedReplicas}')" != "1,1,1,1" ]
then
  echo "ERROR: Deployment status of Httpbin wasn't as expected. Pleae check and try again later."
elif [ "$(kubectl get deployment -n kong ingress-kong -o=jsonpath='{.status.availableReplicas},{.status.readyReplicas},{.status.replicas},{.status.updatedReplicas}')" != "1,1,1,1" ]
then 
  echo "ERROR: Deployment status of Kong wasn't as expected. Pleae check and try again later."
else
  # Forard the service port locally, and track the pid for later
  kubectl port-forward -n kong service/kong-proxy 8081:80 &
  PROC_ID=$!
  secret=XW3iMz6UuqqaTsvQWUeEUTlstvHlA25Z
  username=hmac_tester
  
  TS=$(date -u "+%a, %d %b %Y %T GMT")
  signstring="date: $TS\nGET /hmac HTTP/1.1"
  header="date request-line"
  HMAC=$(printf "$signstring" | openssl dgst -sha256 -hmac $secret -binary | openssl enc -base64 -A)
  authorization="hmac username=\"$username\", algorithm=\"hmac-sha256\", headers=\"$header\", signature=\"$HMAC\""

  # to allow kubectl port-forward time to start
  sleep 3

  # Curl the service
  curl -Ssv "http://localhost:8081/hmac" -H "Authorization:$authorization" -H "Date:$TS" | jq

  # Stop the port forward using its pid
  kill -9 ${PROC_ID}
fi