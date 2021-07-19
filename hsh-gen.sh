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

EC_PPS=$(agent -hsh -smp)
EC_PPS=$(agent -hsh -pvk "$EC_PVK" -pbk "$EC_PBK" -dat "$lic_pps" -smp)
echo step1 $EC_PPS
EC_PPS=$(echo "${EC_PPS##*$'\n'}")
echo step2 $EC_PPS

EC_PPS=$(agent -hsh -smp)

cr_dir=$(find . -name "${lic_id}.cer")
if [ ! -z "$cr_dir" ]; then
  export LIC_PBK=$(cat ${cr_dir}|base64 -w0)
  
  #git log --pretty=oneline --abbrev-commit -- ${cr_dir} | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}'
  #printf "\n\n***** cr_dir: %s\n" "$cr_dir"
  
  CSR_ID=$(git log --pretty=oneline --abbrev-commit -- ${cr_dir} | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}')
  export REQ_EMAIL=$(openssl req -in ./csr-list/$CSR_ID.csr -noout -text | grep -Po '([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)')
  printf "\n\n**** Req Email: %s\n\n" "$REQ_EMAIL"


  # verify if the pk exists
  cd ./../
  git clone https://${EC_TKN}@github.com/EC-Release/pkeys.git
  cs_dir=$(find . -name "${CSR_ID}.key")
  if [ ! -z "$cs_dir" ]; then
    export LIC_PVK=$(cat ${cs_dir}|base64 -w0)
  fi
  cd -
fi

if [[ -z "$LIC_PVK" ]] || [[ -z "$LIC_PBK" ]]; then
  printf "\n\n**** keypair is invalid. Exiting the workflow.\n"
  exit -1
fi

EC_PPS=$(agent -hsh -pvk "$LIC_PVK" -pbk "$LIC_PBK" -smp)
EC_PPS=$(echo "${EC_PPS##*$'\n'}")

echo $EC_PPS > ./hash.txt
echo "lic_email=$REQ_EMAIL" >> $GITHUB_ENV
