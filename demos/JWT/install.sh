#!/usr/bin/env bash

set -uex

cd "${0%/*}"

# Generate private and public keys
openssl genrsa -out jwt-private.pem 2048 2>/dev/null &&\
openssl rsa -in jwt-private.pem -outform PEM -pubout -out jwt-public.pem 2>/dev/null

sleep 1

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
# Create secret for the key
cat <<EOF | cat <(echo) - | cat <(cat manifest.yaml) - | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: jwt-key-rs256
type: Opaque
data:
  kongCredType: $(echo -n "jwt" | base64)
  key: $(echo -n "jwt-rs256-test-key" | base64)
  algorithm: $(echo -n "RS256" | base64)
  rsa_public_key: $(cat jwt-public.pem | base64 -w 0)
EOF
elif [[ "$OSTYPE" == "darwin"* ]]; then
# Create secret for the key
cat <<EOF | cat <(echo) - | cat <(cat manifest.yaml) - | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: jwt-key-rs256
type: Opaque
data:
  kongCredType: $(echo -n "jwt" | base64)
  key: $(echo -n "jwt-rs256-test-key" | base64)
  algorithm: $(echo -n "RS256" | base64)
  rsa_public_key: $(cat jwt-public.pem | base64)
EOF
fi


