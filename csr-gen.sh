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

agent -gen <<MSG
${lic_common}
${lic_country}
${lic_state}
${lic_city}
${lic_zip}
${lic_address}
${lic_organization}
${lic_unit}
${lic_dns}
${lic_email}
${lic_cer_alg}
${lic_key_alg}
no
MSG

rm ca.key ca.cer

op=$(printf "%s" $(ls *.csr | xargs -n 1 basename))
echo "EC_CSR_MSG_TITLE=$op" >> $GITHUB_ENV

fn="${op%.*}"
echo "EC_CSR_ID=$fn" >> $GITHUB_ENV
echo "lic_email=$lic_email" >> $GITHUB_ENV

#pkey="$(cat ./${fn}.key|base64 -w0)"
#echo "lic_pkey=$pkey" >> $GITHUB_ENV

#mv *.csr ./csr-list/
echo "$fn" | tee -a  csr-list.txt > /dev/null

#mv *.csr ./csr-list/
cd ..
git clone https://${EC_TKN}@github.com/EC-Release/x509.git
cd x509
mv ./../certifactory/*.csr ./csr-list/
git add .
git config user.email "EC.Bot@ge.com"
git config user.name "EC Bot"
git commit -m "csr ${fn} checked-in [skip ci]"
git push
cd ./../certifactory


cd ..
git clone https://${EC_TKN}@github.com/EC-Release/pkeys.git
cd pkeys
mv ./../certifactory/${fn}.key ./
git add .
git config user.email "EC.Bot@ge.com"
git config user.name "EC Bot"
git commit -m "pkey ${fn} checked-in [skip ci]"
git push
cd ./../certifactory
#rm *.key
