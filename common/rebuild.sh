#! /bin/bash

display_usage() { 
    echo -e "\nUsage:\n$0 [xos-listen-port] \n" 
} 

if [  $# -lt 1 ] 
then 
    display_usage
    exit 1
fi 

echo "Sending rebuild request to XOS"
STATUS=`curl -X POST 0.0.0.0:$1/api/utility/onboarding/xos/rebuild/ 2> /dev/null`
if [[ "$STATUS" != "true" ]]; then
    echo "Rebuild request failed"
    exit -1
fi

echo "Rebuild request accepted"

