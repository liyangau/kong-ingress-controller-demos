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

echo -e '\n\033[1;4mNo\033[0m Token:'
printf "We are going to make below call WITHOUT token: \n\n"
printf "curl -s http://localhost:8000/basic \n\n"

curl -s http://localhost:8000/basic | jq

token=$( echo "testuser:testpass" | base64 )

printf "\nNext we are going to calculate and use our token. \n\n"
printf "curl -s \"http://localhost:8000/basic\" -H \"Authorization:Basic $token\" \n\n"
pause
# Curl the service once with a consumers credentials to fill the rate limit

# Curl the service

curl -s "http://localhost:8000/basic" -H "Authorization:Basic $token" | jq

# Stop the port forward using its pid
kill -9 $(lsof -t -i tcp:8000)