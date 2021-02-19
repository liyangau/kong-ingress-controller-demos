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

  # to allow kubectl port-forward time to start
  sleep 3

  token=$( echo "testuser:testpass" | base64 )

  # Curl the service
  curl -Ssv "http://localhost:8081/basic" -H "Authorization:Basic $token" | jq

  # Stop the port forward using its pid
  kill -9 ${PROC_ID}
fi