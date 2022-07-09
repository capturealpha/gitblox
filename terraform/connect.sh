#!/bin/bash

source ./utilities/rainbow.sh

USERNAME=`sed -e 's/^"//' -e 's/"$//' <<<$(terraform output prefix)`

if [[ "${2}" != "" ]]; then
	terraform output ${1}-ip | sed ':a;N;$!ba;s/,\n]/]/g' | jq -r ".[${2}]"
	ssh -o "StrictHostKeyChecking no" $USERNAME@$(terraform output ${1}-ip | sed ':a;N;$!ba;s/,\n]/]/g' | jq -r ".[${2}]")
elif [[ ! -z "${1}" ]]; then
	ssh -o "StrictHostKeyChecking no" $USERNAME@$(terraform output ${1}-ip)
else
	echored "Missing ssh target instance!"
fi
