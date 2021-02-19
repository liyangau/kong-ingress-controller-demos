#!/usr/bin/env bash

set -uex

cd "${0%/*}"

cat <<EOF | cat <(echo) - | cat <(cat manifest.yaml) - | kubectl delete -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: jwt-key-rs256
type: Opaque
data:
  kongCredType: $(echo -n "jwt" | base64)
  key: $(echo -n "test-issuer" | base64)
  algorithm: $(echo -n "RS256" | base64)
  rsa_public_key: $(cat jwt-public.pem | base64)
EOF

rm jwt-public.pem
rm jwt-private.pem

# kubectl delete -f manifest.yaml
