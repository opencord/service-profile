#! /bin/bash

display_usage() { 
    echo -e "\nUsage:\n$0 [xos-listen-port] [service-name]\n" 
} 

if [  $# -lt 1 ] 
then 
    display_usage
    exit 1
fi 

if [ $# -eq 2 ]; then
echo "Sending rebuild request to XOS for service $2"
STATUS=`curl -X POST -F "service=$2" 0.0.0.0:$1/api/utility/onboarding/xos/rebuild/ 2> /dev/null`
if [[ "$STATUS" != "true" ]]; then
    echo "Rebuild request failed"
    exit -1
fi
else
echo "Sending rebuild request to XOS"
STATUS=`curl -X POST 0.0.0.0:$1/api/utility/onboarding/xos/rebuild/ 2> /dev/null`
if [[ "$STATUS" != "true" ]]; then
    echo "Rebuild request failed"
    exit -1
fi
fi

echo "Rebuild request accepted"

