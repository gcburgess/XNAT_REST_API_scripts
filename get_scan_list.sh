

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` -j JSESSIONID -s SUBJECT -e SESSION -p intraDB_project_name [-h XNAThost]
Returns CSV-formatted list with:
SessionID,ID,type,series_description,frames,quality,URI,note
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

cmd="curl -s -k --cookie JSESSIONID=$JSESSIONID https://${HOST}/data/projects/${PROJECT}/subjects/${SUBJECT}/experiments/${SESSION}/scans?xsiType=xnat:mrScanData\&format=csv\&columns=ID,xnat:mrSessionData/label,type,series_description,frames,quality,URI,note | $PROJECTS/XNAT_REST_API_scripts/csv_parser.py -c"
#echo $cmd;  #for debugging
eval $cmd;
