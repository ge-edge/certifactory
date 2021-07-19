#!/bin/bash
#
#  Copyright (c) 2019 General Electric Company. All rights reserved.
#
#  The copyright to the computer software herein is the property of
#  General Electric Company. The software may be used and/or copied only
#  with the written permission of General Electric Company or in accordance
#  with the terms and conditions stipulated in the agreement/contract
#  under which the software has been supplied.
#
#  author: apolo.yasuda@ge.com
#

source <(wget -O - https://raw.githubusercontent.com/EC-Release/sdk/disty/scripts/agt/v1.2beta.linux64.txt) -ver

if [[ ! -z "${EC_PPRS}" ]]; then
  export EC_PPS=$EC_PPRS
fi

echo "$EC_PVK" | base64 --decode > ca.key
echo "$EC_PBK" | base64 --decode > ca.cer

EC_PPS=$(agent -hsh -smp)
EC_PPS=$(agent -hsh -pvk ./ca.key -pbk ./ca.cer -dat "$lic_pps" -smp)
EC_PPS=$(echo "${EC_PPS##*$'\n'}")

EC_PPS=$(agent -hsh -smp)
cd ..
git clone https://${EC_TKN}@github.com/EC-Release/x509.git
cd x509

cr_dir=$(find . -name "${lic_id}.cer")
if [ -z "$cr_dir" ]; then
  printf "\n\n**** public cert is invalid. Exiting the workflow.\n"
  exit -1
fi

  #export LIC_PBK=$(cat ${cr_dir}|base64 -w0)
  
  #git log --pretty=oneline --abbrev-commit -- ${cr_dir} | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}'
  #printf "\n\n***** cr_dir: %s\n" "$cr_dir"
export CSR_ID=$(agent -vfy -pbk ${cr_dir} -smp | jq -r '.exts.csrId')
#CSR_ID=$(git log --pretty=oneline --abbrev-commit -- ${cr_dir} | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}')
#export CSR_ID=$(echo ${CSR_ID} | cut -d' ' -f 1)
echo '****' CSR_ID $CSR_ID
#export REQ_EMAIL=$(openssl req -in ./csr-list/$CSR_ID.csr -noout -text | grep -Po '([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)')
export REQ_EMAIL=$(agent -vfy -pbk ${cr_dir} -smp | jq -r '.emailAddress')
printf "\n\n**** Req Email: %s\n\n" "$REQ_EMAIL"

  # verify if the pk exists
cd ./../
git clone https://${EC_TKN}@github.com/EC-Release/pkeys.git
cd pkeys
cs_dir=$(find . -name "${CSR_ID}.key")
if [ -z "$cs_dir" ]; then
  printf "\n\n**** private key is invalid. Exiting the workflow.\n"
  exit -1
    #export LIC_PVK=$(cat ${cs_dir}|base64 -w0)
fi


#if [[ -z "$LIC_PVK" ]] || [[ -z "$LIC_PBK" ]]; then
#  printf "\n\n**** keypair is invalid. Exiting the workflow.\n"
#  exit -1
#fi
cd ./..
EC_PPS=$(agent -hsh -pvk ./pkeys/"$cs_dir" -pbk ./x509/"$cr_dir" -smp)
EC_PPS=$(echo "${EC_PPS##*$'\n'}")

echo $EC_PPS > ./hash.txt
echo "lic_email=$REQ_EMAIL" >> $GITHUB_ENV
tree ./
