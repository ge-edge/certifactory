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

#export CSRID='git log --format=%B -n 1 $(git rev-parse @~)' && openssl req -in ./csr-list/${CSRID}.csr -noout -text
#git log && git log --all --format=%B --grep='.csr' -n 1

: 'export CSR_ID=$(git log --format=%B --no-merges -n 1 | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}')
if [ -z "$CSR_ID" ]; then
    echo ******** invalid csrid: $CSR_ID 
    exit 1
fi'

export SN_NUM=$(openssl req -in csr-list/$CSR_ID.csr -noout -text | grep -Po '[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}')
 
if [ "$CSR_ID" != "$SN_NUM" ]; then
    echo ******** the serialnumber $SN_NUM does not match the csrid: $CSR_ID 
    exit 1
fi
 
echo ******** the serialnumber $SN_NUM matches the csrid $CSR_ID 
openssl req -in csr-list/$CSR_ID.csr -noout -text
