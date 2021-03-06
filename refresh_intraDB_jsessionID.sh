#!/bin/bash
#
# Script:
# Purpose:
# Author:
# Version: $Id$
#


###############################################################################
#
# Environment set up
#
###############################################################################

#shopt -s nullglob # No-match globbing expands to null
call=$(basename $0);
TMPROOT=/tmp
TMPDIR=$TMPROOT/${call%.*}_${$}
trap CleanUp INT

# initialize variables
JSESSIONID="NULL";
HOST="intradb.humanconnectome.org"

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [-j JSESSIONID] [-h XNAThost]

_________________________________________________________________________
\$Id$
EOF
exit
}

CleanUp () {
#	/bin/rm -r $TMPDIR
	exit 0
}


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


###############################################################################
#
# Parse arguments
#
###############################################################################

while (( $# > 1 )) ; do
  case "$1" in
		"-j")
		    shift
		    JSESSIONID="$1"
		    shift
		    ;;
		"-h")
		    shift
		    HOST="$1"
		    shift
		    ;;
		-*)
			echo "ERROR: Unknown option '$1'"
			Usage
			exit 1
			break
			;;
		*)
			break
			;;
  esac
done

## Use this if you expect more arguments (e.g., list of files)
#if (( $# < 1 )) ; then
#	Usage
#fi

###############################################################################
#
# Script Body
#
###############################################################################
## Use this if you want to loop over arguments (e.g., list of files)
#for d in "$@" ; do
#done


refresh_jsession



###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

