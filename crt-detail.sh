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

cd ..
git clone https://${EC_TKN}@github.com/EC-Release/x509.git
cd x509

cr_dir=$(find . -name "${lic_id}.cer")
if [ -z "$cr_dir" ]; then
  printf "\n\n**** public cert is invalid. Exiting the workflow.\n"
  exit -1
fi

agent -vfy -pbk ${cr_dir} -smp | jq .
