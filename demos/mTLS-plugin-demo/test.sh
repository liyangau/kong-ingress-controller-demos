#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}
# Function to sign JWT token HS256 
hs256(){
  secret=$1
  key=$2

  NOW=$( date +%s )
  IAT="${NOW}"

  # expire 9 minutes in the future. 10 minutes is the max for github
  EXP=$((${NOW} + 540))
  jwt_header=$(echo -n '{"alg":"HS256","typ":"JWT"}' | base64 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
  payload=$(echo -n "{\"iat\":\"${IAT}\",\"exp\":${EXP},\"iss\":\"${key}\"}" | base64 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//)
  hexsecret=$(echo -n "$secret" | xxd -p | tr -d '\n')
  hmac_signature=$(echo -n "${jwt_header}.${payload}" |  openssl dgst -sha256 -mac HMAC -macopt hexkey:$hexsecret -binary | base64  | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
  jwt="${jwt_header}.${payload}.${hmac_signature}"
  echo -n "Authorization:Bearer $jwt"
}

# Function to sign JWT token RS256 
rs256(){
  key=$1
  file="$PWD/jwt-private.pem"

  PEM=$( cat ${file} )
  NOW=$( date +%s )
  IAT="${NOW}"
  # expire 9 minutes in the future. 10 minutes is the max for github
  EXP=$((${NOW} + 540))
  HEADER_RAW='{"alg":"RS256","type":"JWT"}'
  HEADER=$( echo -n "${HEADER_RAW}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )
  PAYLOAD_RAW="{\"iat\":${IAT},\"exp\":${EXP},\"iss\":\"${key}\"}"
  PAYLOAD=$( echo -n "${PAYLOAD_RAW}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )
  HEADER_PAYLOAD="${HEADER}"."${PAYLOAD}"
  SIGNATURE=$( openssl dgst -sha256 -sign <(echo -n "${PEM}") <(echo -n "${HEADER_PAYLOAD}") | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

  jwt="${HEADER_PAYLOAD}"."${SIGNATURE}"
  echo -n "Authorization:Bearer $jwt"

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
  sleep 1

  echo -e '\n\033[1;4mNo\033[0m Token:'
  printf "We are going to make below call WITHOUT JWT Token: \n\n"
  printf "curl -i http://localhost:8081/jwt \ \n\
    -H 'X-Kong-Debug: 1' \n\n" 

  curl -Ssv http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1' | jq

  printf "\nNext we are going to try JWT token signed with RS256 algorithm. \n\n"
  echo -e '\033[1;4mRS256\033[0m signature algorithm:'
  authHeader=$( rs256 "jwt-rs256-test-key" )
  printf "curl -i http://localhost:8081/jwt \ \n\
    -H 'X-Kong-Debug: 1' \ \n\
    -H \"$(echo $authHeader)\" \n\n"
  pause
  # Curl the service once with a consumers credentials to fill the rate limit
  curl -Ssv http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1' \
    -H "$(echo $authHeader)" | jq

  printf "\nLastly we are going to try JWT token signed with HS256 algorithm. \n\n"
  echo -e '\033[1;4mHS256\033[0m signature algorithm:'
  authHeader=$( hs256 "jwt-tester-secret" "jwt-tester-key" )
  printf "curl -i http://localhost:8081/jwt \ \n\
    -H 'X-Kong-Debug: 1' \ \n\
    -H \"$(echo $authHeader)\" \n\n"
  pause
  # Curl the service once with a consumers credentials to fill the rate limit
  curl -Ssv http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1' \
    -H "$(echo $authHeader)" | jq
  # Stop the port forward using its pid
  kill -9 ${PROC_ID}
fi