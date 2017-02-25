#!/bin/bash


# Definition of general parameters
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#DIR="$( dirname "$SOURCE" )"
DIR="/home/pi/tasks"
#echo $DIR
WEB_CHECKER='http://whatismyip.akamai.com/'
JSON_FILE=rasp_ipcontroller.json
JSON_DATA=$DIR'/'$JSON_FILE
PYTHON_PARSER="import sys, json; print json.load(sys.stdin)['ip_controller'][last_ip]"

# Function to parse from python JSON
json_key() {
    python -c '
import json
import sys

data = json.load(sys.stdin)

for key in sys.argv[1:]:
    try:
        data = data[key]
    except TypeError:  # This is a list index
        data = data[int(key)]

print(data)' "$@"
}


## Get IPs
#OLD_ID=$(cat rasp_controller.json | jq '.ip_controller.last_ip' | sed -rn '/((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])/p');
#OLD_ID=$(cat rasp_controller.json | python -c "import sys, json; print json.load(sys.stdin)['ip_controller']['last_ip']");
#echo $OLD_ID

NEW_IP=""
while [ -z "$NEW_IP" ]
do
     sleep 2m
     NEW_IP=$(curl -s $WEB_CHECKER);
done

OLD_ID=$(json_key 'ip_controller' 'last_ip' < $JSON_DATA);
SUBJECT=$(json_key 'ip_controller' 'subject' < $JSON_DATA);
EMAIL=$(json_key 'ip_controller' 'email' < $JSON_DATA);
#echo $NEW_IP
#echo $OLD_ID
#echo $SUBJECT
#echo $EMAIL
#echo 's/'$OLD_ID'/'$NEW_IP'/g'

## Store or manage the IP
if [ $"$NEW_IP" != $OLD_ID ]
    then 
#    echo "$NEW_IP"
#    echo "$SUBJECT"
    sed -ie 's/'$OLD_ID'/'$NEW_IP'/g' $JSON_DATA
    echo "$NEW_IP" | mail -s "$SUBJECT" $EMAIL
    rm $JSON_DATA'e'
fi


