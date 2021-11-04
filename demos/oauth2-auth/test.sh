#!/usr/bin/env bash

set -e

pause(){
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n\n'
}

# Forard the service port locally, and track the pid for later
kubectl port-forward -n kong service/kong-proxy 8443:443 &
# PROC_ID=$!

# to allow kubectl port-forward time to start
sleep 3

echo -e '\nRequest without \033[1;4maccess_token\033[0m:'
printf "curl -skv https://localhost:8443/test | jq \n\n" 
pause
curl -skv https://localhost:8443/test | jq

printf "As we can see the authentication failed. \n\n"

auth_code_flow(){
  echo -e "
***********************************************
* We are going to demo \033[1;4mAuthorization Code\033[0m flow
***********************************************
"
  printf "Firstly we need to request a code from authorization endpoint: \n\n"
  printf "curl -X POST --silent \ \n\
    --url \"https://localhost:8443/test/oauth2/authorize\" \ \n\
    --data \"response_type=code\" \ \n\
    --data \"scope=email address\" \ \n\
    --data \"client_id=oauth2-demo-client-id\" \ \n\
    --data \"provision_key=oauth2-demo-provision-key\" \ \n\
    --data \"authenticated_userid=authenticated_tester\" \ \n\
    --insecure | jq \n\n" 
  pause

  AUTH_CODE=$(curl -X POST --silent \
    --url "https://localhost:8443/test/oauth2/authorize" \
    --data "response_type=code" \
    --data "scope=email address" \
    --data "client_id=oauth2-demo-client-id" \
    --data "provision_key=oauth2-demo-provision-key" \
    --data "authenticated_userid=authenticated_tester" \
    --insecure | jq )

  printf "\nWe will get our response as below: \n"
  echo $AUTH_CODE | jq
  AUTH_CODE=$(echo $AUTH_CODE | jq -r '.redirect_uri' | sed 's/.*code=//')
  echo -e "I am going to store $AUTH_CODE in environment variable \033[1mAUTH_CODE\033[0m. \n"

  printf "Next we will request access_token with AUTH_CODE: \n\n"
  printf "curl -X POST --silent \ \n\
    --url \"https://localhost:8443/test/oauth2/token\" \ \n\
    --data \"grant_type=authorization_code\" \ \n\
    --data \"client_id=oauth2-demo-client-id\" \ \n\
    --data \"client_secret=oauth2-demo-client-secret\" \ \n\
    --data \"code=$AUTH_CODE\" \ \n\
    --insecure | jq \n\n" 
  pause

  ACCESS_TOKEN=$(curl -X POST --silent \
    --url "https://localhost:8443/test/oauth2/token" \
    --data "grant_type=authorization_code" \
    --data "client_id=oauth2-demo-client-id" \
    --data "client_secret=oauth2-demo-client-secret" \
    --data "code=$AUTH_CODE" \
    --insecure | jq )

  printf "We will get our response as below: \n"
  echo $ACCESS_TOKEN | jq
  ACCESS_TOKEN=$(echo $ACCESS_TOKEN | jq -r '.access_token')
  echo -e "I am going to store $ACCESS_TOKEN in environment variable \033[1mACCESS_TOKEN\033[0m \n"

  printf "Now we can authenticate with ACCESS_TOKEN: \n\n"
  printf "curl -skv https://localhost:8443/test/anything \ \n\
    -H \"Authorization:Bearer $ACCESS_TOKEN\" | jq \n\n" 
  pause

  curl -skv https://localhost:8443/test/anything -H "Authorization:Bearer $ACCESS_TOKEN" | jq
}

implicit_flow(){
  echo -e "
***********************************************
* We are going to demo \033[1;4mImplicit\033[0m flow
***********************************************
"
  printf "We are going to get access_token at authorization endpoint with below call: \n\n"
  printf "curl -X POST --silent \ \n\
    --url \"https://localhost:8443/test/oauth2/authorize\" \ \n\
    --data \"grant_type=token\" \ \n\
    --data \"client_id=oauth2-demo-client-id\" \ \n\
    --data \"provision_key=oauth2-demo-provision-key\" \ \n\
    --data \"authenticated_userid=authenticated_tester\" \ \n\
    --insecure | jq \n\n" 
  pause

  ACCESS_TOKEN=$(curl -X POST --silent \
    --url "https://localhost:8443/test/oauth2/authorize" \
    --data "response_type=token" \
    --data "scope=email address" \
    --data "client_id=oauth2-demo-client-id" \
    --data "provision_key=oauth2-demo-provision-key" \
    --data "authenticated_userid=authenticated_tester" \
    --insecure | jq )

  printf "We will get our response as below: \n"
  echo $ACCESS_TOKEN | jq
  ACCESS_TOKEN=$(echo $ACCESS_TOKEN | jq -r ".redirect_uri" | awk -v FS="(access_token=|&)" '{print $2}')
  echo -e "I am going to store $ACCESS_TOKEN in environment variable \033[1mACCESS_TOKEN\033[0m \n"

  printf "Now we can authenticate with ACCESS_TOKEN: \n\n"
  printf "curl -skv https://localhost:8443/test/anything \ \n\
    -H \"Authorization:Bearer $ACCESS_TOKEN\" | jq \n\n" 
  pause

  curl -skv https://localhost:8443/test/anything -H "Authorization:Bearer $ACCESS_TOKEN" | jq
}

password_flow(){
  echo -e "
***********************************************
* We are going to demo \033[1;4mPassword\033[0m flow
***********************************************
"
  printf "We are going to get access_token at token endpoint with below call: \n\n"
  printf "curl -X POST --silent \ \n\
    --url \"https://localhost:8443/test/oauth2/token\" \ \n\
    --data \"grant_type=password\" \ \n\
    --data \"scope=email address\" \ \n\
    --data \"client_id=oauth2-demo-client-id\" \ \n\
    --data \"client_secret=oauth2-demo-client-secret\" \ \n\
    --data \"provision_key=oauth2-demo-provision-key\" \ \n\
    --data \"authenticated_userid=authenticated_tester\" \ \n\
    --insecure | jq \n\n" 
  pause

  ACCESS_TOKEN=$(curl -X POST --silent \
    --url "https://localhost:8443/test/oauth2/token" \
    --data "grant_type=password" \
    --data "scope=email address" \
    --data "client_id=oauth2-demo-client-id" \
    --data "client_secret=oauth2-demo-client-secret" \
    --data "provision_key=oauth2-demo-provision-key" \
    --data "authenticated_userid=authenticated_tester" \
    --insecure | jq )

  printf "We will get our response as below: \n"
  echo $ACCESS_TOKEN | jq
  ACCESS_TOKEN=$(echo $ACCESS_TOKEN | jq -r '.access_token')
  echo -e "I am going to store $ACCESS_TOKEN in environment variable \033[1mACCESS_TOKEN\033[0m \n"

  printf "Now we can authenticate with ACCESS_TOKEN: \n\n"
  printf "curl -skv https://localhost:8443/test/anything \ \n\
    -H \"Authorization:Bearer $ACCESS_TOKEN\" | jq \n\n" 
  pause

  curl -skv https://localhost:8443/test/anything -H "Authorization:Bearer $ACCESS_TOKEN" | jq
}

client_cred_flow(){
  echo -e "
***********************************************
* We are going to demo \033[1;4mClient Credential\033[0m flow
***********************************************
"
  printf "We are going to get access_token at token endpoint with below call: \n\n"
  printf "curl -X POST --silent \ \n\
    --url \"https://localhost:8443/test/oauth2/token\" \ \n\
    --data \"grant_type=client_credentials\" \ \n\
    --data \"scope=email address\" \ \n\
    --data \"client_id=oauth2-demo-client-id\" \ \n\
    --data \"client_secret=oauth2-demo-client-secret\" \ \n\
    --data \"provision_key=oauth2-demo-provision-key\" \ \n\
    --insecure | jq \n\n" 
  pause

  ACCESS_TOKEN=$(curl -X POST --silent \
    --url "https://localhost:8443/test/oauth2/token" \
    --data "grant_type=client_credentials" \
    --data "scope=email address" \
    --data "client_id=oauth2-demo-client-id" \
    --data "client_secret=oauth2-demo-client-secret" \
    --data "provision_key=oauth2-demo-provision-key" \
    --insecure | jq )

  printf "We will get our response as below: \n"
  echo $ACCESS_TOKEN | jq
  ACCESS_TOKEN=$(echo $ACCESS_TOKEN | jq -r '.access_token')
  echo -e "I am going to store $ACCESS_TOKEN in environment variable \033[1mACCESS_TOKEN\033[0m \n"

  printf "Now we can authenticate with ACCESS_TOKEN: \n\n"
  printf "curl -skv https://localhost:8443/test/anything \ \n\
    -H \"Authorization:Bearer $ACCESS_TOKEN\" | jq \n\n" 
  pause

  curl -skv https://localhost:8443/test/anything -H "Authorization:Bearer $ACCESS_TOKEN" | jq
}

while getopts "t:" opt
do
   case "$opt" in
      t ) type="$OPTARG" ;;
   esac
done

if [ -z "$type" ]
then
  auth_code_flow
  implicit_flow
  password_flow
  client_cred_flow
elif [ "$type" = "auth_code" ]
then
  auth_code_flow
elif [ "$type" = "implicit" ]
then
  implicit_flow
elif [ "$type" = "password" ]
then
  password_flow
elif [ "$type" = "client_cred" ]
then
  client_cred_flow
else 
  echo "Unable to find this flow, please try again."
fi

kill -9 $(lsof -t -i tcp:8443)