#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}

# Forard the service port locally, and track the pid for later
kubectl port-forward -n kong service/kong-proxy 8000:80 &

# to allow kubectl port-forward time to start
sleep 3

echo -e '\n\033[1;4mNo\033[0m API Key:'
printf "We are going to make below call WITHOUT API key: \n\n"
printf "curl -sv http://localhost:8000/acl | jq \n\n" 
pause
curl -sv http://localhost:8000/acl | jq

printf "\nNext we are going to try with an API key for consumer in group-2. \n\n"
printf "curl -i http://localhost:8000/acl \ \n\
  -H 'apikey: api-secret-key-2' | jq \n\n"
pause
curl -sv http://localhost:8000/acl \
  -H 'apikey: api-secret-key-2' | jq

printf "\nAs we can see authenticaiton passed but this user is not allowed to consume the service. \n Let's try again with api key belongs to a user from grup-1. \n\n"
printf "curl -i http://localhost:8000/acl \ \n\
  -H 'apikey: api-secret-key-1' | jq \n\n"
pause
# Curl the service once with a consumers credentials to fill the rate limit
curl -sv http://localhost:8000/acl \
  -H 'apikey: api-secret-key-1' | jq

# Stop the port forward using its pid
kill -9 $(lsof -t -i tcp:8000)