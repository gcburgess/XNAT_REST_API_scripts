#!/bin/bash

# specify remote server
if [ -z "$HOST" ]
then
	HOST="intradb.humanconnectome.org"
fi

# specify project
PROJECT="CCF_HCA_ITK"

# Verify JSESSIONID
if [ -z "$JSESSIONID" ]
then
	echo "\$JSESSIONID is null. Requesting new session."
	JSESSIONID="junk";
else
	echo "Refreshing \$JSESSIONID."
fi 
JSESSIONID=$( $PROJECTS/XNAT_REST_API_scripts/refresh_intraDB_jsessionID.sh -j $JSESSIONID)



cmd="curl -s -k --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/experiments?xsiType=san:sanityChecks\&format=csv\&columns=ID,label,URI,san:sanityChecks/overall/status\&project=${PROJECT} | grep \"FAILED\" | sed -e \"s/^.*,//\" | sort | grep 'experiments' | xargs -I '{}' sh -c \"echo -e '\n'; curl -s -k --cookie JSESSIONID=$JSESSIONID https://${HOST}{}?format=xml\" | egrep \"^$|FAIL|label=\" | sed -e 's/xmlns:prov.*$//'"
echo "RUNNING following command, writing output to ${HOME}/Desktop/Sanity_Checks.xml"
echo $cmd;
eval "$cmd > ${HOME}/Desktop/Sanity_Checks.xml"



