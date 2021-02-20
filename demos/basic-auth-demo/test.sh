#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}

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

  echo -e '\n\033[1;4mNo\033[0m Token:'
  printf "We are going to make below call WITHOUT token: \n\n"
  printf "curl -i http://localhost:8081/basic \n\n" 

  curl -Ssv http://localhost:8081/basic | jq

  printf "\nNext we are going to calculate and use our token. \n\n"
  token=$( echo "testuser:testpass" | base64 )
  printf "curl -Ssv \"http://localhost:8081/basic\" -H \"Authorization:Basic $token\" \n\n"
  pause
  # Curl the service once with a consumers credentials to fill the rate limit
  # Curl the service
  curl -Ssv "http://localhost:8081/basic" -H "Authorization:Basic $token" | jq

  # Stop the port forward using its pid
  kill -9 ${PROC_ID}
fi