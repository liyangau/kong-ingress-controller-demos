#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}

# Forard the service port locally, and track the pid for later
kubectl port-forward -n kong service/kong-proxy 8000:80 &

sleep 3

secret=XW3iMz6UuqqaTsvQWUeEUTlstvHlA25Z
username=hmac_tester

echo -e '\n\033[1;4mNo\033[0m Token:'
printf "We are going to make below call WITHOUT token: \n\n"
printf "curl -sv http://localhost:8000/hmac \n\n" 

curl -sv http://localhost:8000/hmac | jq

TS=$(date -u "+%a, %d %b %Y %T GMT")
signstring="date: $TS\nGET /hmac HTTP/1.1"
header="date request-line"
HMAC=$(printf "$signstring" | openssl dgst -sha256 -hmac $secret -binary | openssl enc -base64 -A)
authorization="hmac username=\"$username\", algorithm=\"hmac-sha256\", headers=\"$header\", signature=\"$HMAC\""

printf "\nNext we are going to calculate and use our signature. \n\n"
printf "curl -sv \"http://localhost:8000/hmac\" \n -H \"Authorization:$authorization\" \n -H \"Date:$TS\" \n\n"
pause

# Curl the service
curl -sv "http://localhost:8000/hmac" -H "Authorization:$authorization" -H "Date:$TS" | jq

# Stop the port forward using its pid
kill -9 $(lsof -t -i tcp:8000)