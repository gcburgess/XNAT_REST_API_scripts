#!/bin/bash

HOST='intradb.humanconnectome.org'

while (( $# > 1 )) ; do
  case "$1" in
    "-help")
      #Usage
      ;;
    "-j")
      shift
	    JSESSIONID="$1"
	    shift
	    ;;
  esac
done


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

refresh_jsession () {
	if [ -n "$JSESSIONID" ]; then	# if jsession not empty, check if it's good
		# Check that JSESSIONID from parent proc is still good and get new one if not
		http_code=$(curl -I -s -o /dev/null -k --cookie "JSESSIONID=$JSESSIONID" \
			-w "%{http_code}" https://$HOST/data/projects)
	fi

	if [[ ! "$http_code" == "200" ]]; then	# jsession is old or blank
		get_jsession;
	else 									# jsession is new and fresh
		echo $JSESSIONID;
	fi
}

refresh_jsession
