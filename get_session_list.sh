#!/bin/bash


###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` -j JSESSIONID [-p intraDB_project_name] [-h XNAThost]
Returns CSV-formatted list with:
SubjectID,SessionID,Project,Scanner,Site,Date,Operator
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

# get info session fields that I always want to know
# Use python csv_parser.py to handle Operator field 
# because of commas inside of quotes 
# SubjectID,SessionID,Project,Scanner,Site,Date,ExperimentID,Operator

cmd="curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/data/experiments?xsiType=xnat:mrSessionData\&format=csv\&columns=project,subject_label,label,xnat:imageSessionData/scanner,xnat:imageSessionData/operator,xnat:experimentdata/date"

#echo $cmd;  #for debugging
eval $cmd | grep "$PROJECT" | $PROJECTS/XNAT_REST_API_scripts/csv_parser.py -s | \
     sed -e 's|TRIOC|TRIOC,UMN-TRIOC|' -e 's|AWP166007|AWP166007,UMN-AWP|' -e 's|AWP166038|AWP166038,WU-Bay2|' -e 's|MRC35177|MRC35177,WU-Bay3|' -e 's|AWP67056|AWP67056,Harvard|' -e 's|BAY4OC|BAY4OC,MGH|' -e 's|MRC35343|MRC35343,UCLA-BMC|' -e 's|MRC35426|MRC35426,UCLA-CCN|' 


#curl -k -s --cookie JSESSIONID=$JSESSIONID https://intradb.humanconnectome.org/data/subjects?format=csv\&columns=ID,URI,age
#curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/data/experiments?xsiType=xnat:mrSessionData\&format=csv\&columns=project,subject_label,label,xnat:imageSessionData/scanner,xnat:imageSessionData/operator,xnat:experimentdata/date,xnat:subjectData/demographics