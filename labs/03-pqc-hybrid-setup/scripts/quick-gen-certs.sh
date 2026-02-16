#!/bin/bash
# Quick one-command certificate generation for PQC Hybrid TLS
# This script combines all steps into a single command

CONTAINER="${1:-pqc-hybrid-nginx}"

docker exec "$CONTAINER" bash -c '
set -e
echo "Fixing library paths..."
echo "/opt/openssl/lib64" > /etc/ld.so.conf.d/openssl.conf
echo "/opt/oqs/lib" > /etc/ld.so.conf.d/liboqs.conf
ldconfig

cd /tmp
echo "Generating ECDSA certificate..."
openssl ecparam -name prime256v1 -genkey -out ecdsa.key
openssl req -new -x509 -key ecdsa.key -out ecdsa.crt -days 365 -subj "/CN=pqc-lab.local/O=PQC Lab/C=TH"

echo "Generating ML-DSA certificate..."
openssl genpkey -algorithm mldsa65 -provider oqsprovider -out mldsa.key
openssl req -new -x509 -key mldsa.key -provider oqsprovider -provider default -out mldsa.crt -days 365 -subj "/CN=pqc-lab.local/O=PQC Lab/C=TH"

echo "Copying to nginx directory..."
cp ecdsa.* mldsa.* /etc/nginx/certs/
chmod 644 /etc/nginx/certs/*.crt
chmod 600 /etc/nginx/certs/*.key

echo "✓ Done! Certificates generated:"
ls -lh /etc/nginx/certs/*.{crt,key} 2>/dev/null | grep -E "ecdsa|mldsa"
'
