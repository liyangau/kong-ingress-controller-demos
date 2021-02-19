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

  echo -e '\n\033[1;4mNo\033[0m API Key:'
  printf "We are going to make below call WITHOUT API key: \n\n"
  printf "curl -i http://localhost:8081/keyauth \ \n\
    -H 'X-Kong-Debug: 1' \n\n" 

  curl -Ssv http://localhost:8081/keyauth \
    -H 'X-Kong-Debug: 1' | jq

  printf "\nNext we are going to try with an API key. \n\n"
  printf "curl -i http://localhost:8081/keyauth \ \n\
    -H 'X-Kong-Debug: 1' \ \n\
    -H 'apikey: api-secret-key' \n\n"
  pause
  curl -Ssv http://localhost:8081/keyauth \
    -H 'X-Kong-Debug: 1' \
    -H 'apikey: api-secret-key' | jq
  
  printf "\nBy default, we can also put apikey in querystring. \n\n"
  printf "curl -i http://localhost:8081/keyauth?apikey=api-secret-key \ \n\
    -H 'X-Kong-Debug: 1' \ \n\n"
  pause
  # Curl the service once with a consumers credentials to fill the rate limit
  curl -Ssv http://localhost:8081/keyauth?apikey=api-secret-key \
    -H 'X-Kong-Debug: 1' | jq

  # Stop the port forward using its pid
  kill -9 ${PROC_ID}
fi