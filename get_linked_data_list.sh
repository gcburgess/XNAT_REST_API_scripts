#!/bin/bash

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` -j JSESSIONID -s SUBJECT -e SESSION -p intraDB_project_name [-h XNAThost]
Returns CSV-formatted list with:
SUBJECT,SESSION,URI
_________________________________________________________________________
\$Id$
EOF
exit
}



###############################################################################
#
# Parse arguments
#
###############################################################################

if (( $# < 1 )) ; then
    Usage
fi

HOST=intradb.humanconnectome.org
PROJECT=""

while (( $# > 1 )) ; do
    case "$1" in
    "-help")
        Usage
        ;;
	"-j")
	    shift
	    JSESSIONID="$1"
	    shift
	    ;;
	"-p")
	    shift
	    PROJECT="$1"
	    shift
	    ;;
	"-s")
	    shift
	    SUBJECT="$1"
	    shift
	    ;;
	"-e")
	    shift
	    SESSION="$1"
	    shift
	    ;;
	"-h")
	    shift
	    HOST="$1"
	    shift
	    ;;
	-*)
		echo "ERROR: Unknown option '$1'"
		exit 1
		break
		;;
	*)
		break
		;;
    esac
done

# get info about scan fields that I always want to know
# SessionID,ID,type,series_description,frames,quality,URI,note

#curl -k -s --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/archive/projects/${PROJECT}/subjects/${SUBJECT}/experiments/${SESSION}/scans/${SCAN}/resources/LINKED_DATA/files?format=csv
#cmd="curl -k -s --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/archive/projects/${PROJECT}/subjects/${SUBJECT}/experiments/${SESSION}/scans/${SCAN}/resources/LINKED_DATA/files?format=csv | grep -v URI | cut -d',' -f3"
#echo $cmd;  #for debugging


# get linked data for all scans in session
URL="https://${HOST}/data/archive/projects/${PROJECT}/subjects/${SUBJECT}/experiments/${SESSION}/scans/*/resources/LINKED_DATA/files?format=csv"
curl -k -s --cookie JSESSIONID=$JSESSIONID -X GET $URL | sed 's/\"//g' | grep LINKED_DATA | cut -d',' -f3 | \
while read line; do
	echo "$SUBJECT,$SESSION,$PROJECT,$line";
done

# get linked data from session-level resources
URL="https://${HOST}/data/archive/projects/${PROJECT}/subjects/${SUBJECT}/experiments/${SESSION}/resources/LINKED_DATA/files?format=csv"
curl -k -s --cookie JSESSIONID=$JSESSIONID -X GET $URL | sed 's/\"//g' | grep LINKED_DATA | cut -d',' -f3 | \
while read line; do
	echo "$SUBJECT,$SESSION,$PROJECT,$line";
done
