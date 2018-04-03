#!/bin/bash


HOST='intradb.humanconnectome.org'

get_jsession() {
	if [ -e "${HOME}/.intradb.curl.conf" ]
	then
		JSESSIONID=`curl -s -K ${HOME}/.intradb.curl.conf https://$HOST/data/JSESSIONID`
	else
		read -s -p "ENTER $HOST USERNAME: " USERNAME;
		read -s -p "ENTER PASSWORD for $USERNAME at $HOST: " PW;
		echo "Getting session permissions..."
		echo
		JSESSIONID=`curl -s -k -u $USERNAME:$PW https://$HOST/data/JSESSIONID`;
	fi
	echo $JSESSIONID;
}

get_jsession;
