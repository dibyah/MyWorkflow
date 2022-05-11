#!/bin/bash
echo "token started"
abc=$(curl --location --request POST 'https://zscaler-poc.us.auth0.com/oauth/token' --header 'Content-Type: application/json' --data-raw '{ "audience" : "https://api.zscwp.io/iac", "grant_type" : "client_credentials", "client_id" : "rB7KjO6hjAM5NqCir0ii0A8USPelGmiz", "client_secret" : "FvnQ6cvOVPO7Y7x3Nu2MBzzuWv1uGi9KwX7yEotnb6WQIooBmaMzzN9jKSJQNPj1"}')
echo $abc
echo "token call done"
regex_hint=access_token
[[ $abc =~ $regex_hint\":\"(.+)\",\"expires_in\" ]]
token=${BASH_REMATCH[1]}
echo $token
$(curl --location --request GET 'https://main.dev.api.zscwp.io/iac/onboarding/v1/cli/download?version=e101670&platform=Linux&arch=x86_64' \
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
zscanner config add -k custom_region -v "{\"host\":\"https://int.api.zscwp.io\",\"auth\":{\"host\":\"https://z-cwp-int.us.auth0.com\",\"clientId\":\"umf1171zFcAiYsVwqhohFlLS8MoNQI3I\",\"scope\":\"offline_access profile\",\"audience\":\"https://api.zscwp.io/iac\"}}"
zscanner config list -a
zscanner logout
checkLogin=`zscanner login cc --client-id umf1171zFcAiYsVwqhohFlLS8MoNQI3I --client-secret nc11wyU9l_PmEAXywXE-A4ZFm79FGpMe2wuvTRv8zbMBMvKNeFipzkVXmnxTz-cC -r CUSTOM`
loginString='Logged in as system'
if [ "$checkLogin" == "$loginString" ]
then
  echo "successfully login to system"
else
  echo "Failed to login to system"
fi
zscanner scan -d .
if [ $? == 0 ]
then
  echo "Scan passed and no violations"
else
  echo "Scan Violations reported"
  exit 1
fi
