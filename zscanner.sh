#!/bin/bash
echo "token started"
abc=$(curl --location --request POST 'https://zscaler-poc.us.auth0.com/oauth/token' --header 'Content-Type: application/json' --data-raw '{ "audience" : "https://api.zscwp.io/iac", "grant_type" : "client_credentials", "client_id" : "FNfqUXnMz2G1NpOegRfq4ErrqeW9uoRO", "client_secret" : "z69wXARMKZ1tQNZMkLCSWn6E2iglDQrMl7UF1hMhrlvZG-FrsaXkq7c9Aha_hjEB"}')
echo $abc
echo "token call done"
regex_hint=access_token
[[ $abc =~ $regex_hint\":\"(.+)\",\"expires_in\" ]]
token=${BASH_REMATCH[1]}
echo $token
$(curl --location --request GET 'https://main.dev.api.zscwp.io/iac/onboarding/v1/cli/download?version=6b9e229&platform=Linux&arch=x86_64' \
--header "Authorization: Bearer $token" \
--header 'Content-Type: application/json' \
--data-raw '{
    "platform": "Linux",
    "arch": "x86_64"
}' --output zscanner_binary.tar.gz)
echo "binary downloaded"
$(tar -xf zscanner_binary.tar.gz)
echo "retrieved zscanner"
$(sudo install zscanner /usr/local/bin && rm zscanner)
echo "check zscanner"
zscanner version
zscanner config list -a
zscanner config add -k custom_region -v "{\"host\":\"https://main.dev.api.zscwp.io\",\"auth\":{\"host\":\"https://zscaler-poc.us.auth0.com\",\"clientId\":\"FNfqUXnMz2G1NpOegRfq4ErrqeW9uoRO\",\"scope\":\"offline_access profile\",\"audience\":\"https://api.zscwp.io/iac\"}}"
zscanner config add -k secure-storage -v "false"
zscanner config list -a
zscanner logout
checkLogin=`zscanner login cc --client-id FNfqUXnMz2G1NpOegRfq4ErrqeW9uoRO --client-secret z69wXARMKZ1tQNZMkLCSWn6E2iglDQrMl7UF1hMhrlvZG-FrsaXkq7c9Aha_hjEB -r CUSTOM`
loginString='Logged in as system'
if [ "$checkLogin" == "$loginString" ]
then
  echo "successfully login to system"
else
  echo "Failed to login to system"
fi
zscanner scan -d .
