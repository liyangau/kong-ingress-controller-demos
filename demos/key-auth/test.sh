#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}

# Forard the service port locally, and track the pid for later
kubectl port-forward -n kong service/kong-proxy 8000:80 &
# PROC_ID=$!

# to allow kubectl port-forward time to start
sleep 3

echo -e '\n\033[1;4mNo\033[0m API Key:'
printf "We are going to make below call WITHOUT API key: \n\n"
printf "curl -s http://localhost:8000/keyauth | jq \n\n" 
pause
curl -s http://localhost:8000/keyauth | jq

printf "\nNext we are going to try with an API key. \n\n"
printf "curl -i http://localhost:8000/keyauth \ \n\
  -H 'apikey: api-secret-key' | jq \n\n"
pause
curl -s http://localhost:8000/keyauth \
  -H 'apikey: api-secret-key' | jq

printf "\nBy default, we can also put apikey in querystring. \n\n"
printf "curl -s http://localhost:8000/keyauth?apikey=api-secret-key | jq \n\n"
pause
# Curl the service once with a consumers credentials to fill the rate limit
curl -s http://localhost:8000/keyauth?apikey=api-secret-key | jq

# Stop the port forward using its pid
kill -9 $(lsof -t -i tcp:8000)