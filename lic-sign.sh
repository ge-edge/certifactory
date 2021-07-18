#!/bin/bash

ref0=$(git rev-parse HEAD)
ref1=$(git log --format=%B -n 1 $ref0 | head -n 1)
ref2=$(printf "%s" "${ref1#*/beta-}")
export CSR_ID="${ref2%.*}"
printf "\n\n**** CSR_ID: %s\n\n" "$CSR_ID"

export REQ_EMAIL=$(openssl req -in ./csr-list/$CSR_ID.csr -noout -text | grep -Po '([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)')
printf "\n\n**** Req Email: %s\n\n" "$REQ_EMAIL"
echo "lic_email=$REQ_EMAIL" >> $GITHUB_ENV

# ensure to issue the enclosed license in below dir 
mkdir -p cert-list/beta
cd cert-list/beta/

source <(wget -O - https://raw.githubusercontent.com/EC-Release/sdk/disty/scripts/agt/v1.2beta.linux64.txt) -ver

if [[ ! -z "${EC_PPRS}" ]]; then
  export EC_PPS=$EC_PPRS
fi

echo $EC_PVK | base64 --decode > ca.key
echo $EC_PBK | base64 --decode > ca.cer

EC_PPS=$(agent -hsh -smp)
agent -sgn <<MSG
ca.key
365
DEVELOPER
EC_ECO
Seat_x1
./../../csr-list/${CSR_ID}.csr
no 
ca.cer
MSG

rm ca.key ca.cer

ref7=$(ls -Art | tail -n 1)
export DEV_ID="${ref7%.*}"
echo "DEV_ID=$DEV_ID" >> $GITHUB_ENV
cp $ref7 ./../../../license.txt

ls -al ./ && ls -al ./../..
cd -
