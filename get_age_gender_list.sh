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
HOST=intradb.humanconnectome.org

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` -j JSESSIONID -p intraDB_project_name [-h XNAThost]
Returns CSV-formatted list with:
SubjectID,age,URI
_________________________________________________________________________
\$Id$
EOF
exit
}

CleanUp () {
#	/bin/rm -r $TMPDIR
	exit 0
}


###############################################################################
#
# Parse arguments
#
###############################################################################

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

# need age
#  https://intradb.humanconnectome.org/data/subjects?format=csv\&columns=ID,URI,age

#curl -s -k --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/subjects?columns=label,age\&format=csv\&project=${PROJECT}\&label=${SUBJECT}
curl -s -k --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/subjects?columns=label,age,gender\&format=csv\&project=${PROJECT} | grep -v 'age' | cut -d',' -f2-5


###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

