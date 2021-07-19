#!/bin/bash
: 'echo "$DEV_ID" | tee -a  crt-list.txt > /dev/null
git config user.email "EC.Bot@ge.com"
git config user.name "EC Bot"
git add crt-list.txt
git commit -m "licensed to $CSR_ID [skip ci]"
git checkout -b disty
git pull origin disty
git merge beta
git push origin disty'

cd ..
cd x509
#mv ./../certifactory/cert-list/${DEV_ID}.cer ./crt-list/
echo "$DEV_ID".cer licensed to "$CSR_ID".csr | tee -a  crt-list.txt > /dev/null
git add .
git config user.email "EC.Bot@ge.com"
git config user.name "EC Bot"
git commit -m "licensed to $CSR_ID [skip ci]"
git push
cd ./../certifactory
