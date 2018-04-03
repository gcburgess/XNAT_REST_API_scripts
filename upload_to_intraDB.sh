#!/bin/bash

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` -j JSESSIONID -p PROJECT -s SUBJECT -e SESSION -d DATADIR

-j JSESSIONID	(UUID for active session; optional)
-p PROJECT (example: CCF_HCD_ITK or CCF_HCA_ITK)
-s SUBJECT (example: HCD1234567)
-e SESSION (example: HCD1234567_V1_A)
-d DATADIR location of files for each session to upload
	(example: /PATH/TO/PSYCHOPY_DATA)
	
_________________________________________________________________________
\$Id$
EOF
exit
}

###############################################################################
#
# Initialize Variables
#
###############################################################################

HOST="intradb.humanconnectome.org";
PROJECT=CCF_HCD_ITK
SUBJECT=HCD0147333
SESSION=HCD0147333_V1_B
DATADIR="/home/shared/HCP/taskfmri/phase2/fmri/WORK/GREG_work/LIFESPAN_PSYCHOPY_DATA/clean_data"

###############################################################################
#
# Parse arguments
#
###############################################################################
if (( $# < 1 )) ; then
    Usage
fi

while (( $# > 1 )) ; do
	case "$1" in
		"-help")
			Usage
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
		"-d")
			shift
			DATADIR="$1"
			shift
			;;
		"-j")
			shift
			JSESSIONID="$1"
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

###############################################################################
#
# Script Body
#
###############################################################################

DATAPATH=${DATADIR}/${SESSION}
 
## GET JSESSIONID
if [ -n "$JSESSIONID" ]; then	# if jsession not empty, check if it's good
	JSESSIONID=$( $PROJECTS/XNAT_REST_API_scripts/refresh_intraDB_jsessionID.sh -j $JSESSIONID );
else
	JSESSIONID=$( $PROJECTS/XNAT_REST_API_scripts/refresh_intraDB_jsessionID.sh );
fi
echo "JSESSIONID=$JSESSIONID"
 
## GET SERVER-SIDE CACHE SPACE PATH TO BE USED FOR THIS UPLOAD
BUILDPATH=`curl -s --cookie JSESSIONID=$JSESSIONID -X POST "https://$HOST/REST/services/import?import-handler=automation&project=$PROJECT&subject=$SUBJECT&experiment=$SESSION&returnUrlList=false&importFile=false&process=false" | sed "s/\/[^\/]*$//"`
echo "BUILDPATH=$BUILDPATH"

## TELL IMPORTER TO PROCESS ALL FILES
# needs to indicate which automation script should be run
if [[ "$PROJECT" == "CCF_HCA_ITK" ]]; then
	EVENTHANDLER="CCF_HCA_LinkedDataImporter-prj_CCF_HCA_ITK-LinkedDataUpload--112114798-0";
elif [[ "$PROJECT" == "CCF_HCD_ITK" ]]; then
	EVENTHANDLER="CCF_HCD_LinkedDataImporter-prj_CCF_HCD_ITK-LinkedDataUpload--112114798-0";
else
	echo "Unknown project $PROJECT, eventHandler not known";
	exit;
fi

## UPLOAD EACH FILE TO CACHE SPACE
for FPATH in `find $DATAPATH -type f`; do
	FNAME=`basename $FPATH`
	echo "SEND FILE:  FILE PATH=$FPATH, FILE NAME=$FNAME"
	curl -s --cookie JSESSIONID=$JSESSIONID --data-binary @$FPATH -X POST "https://$HOST/REST/services/import/$FNAME?import-handler=automation&project=$PROJECT&subject=$SUBJECT&experiment=$SESSION&buildPath=$BUILDPATH&returnUrlList=false&extract=true&process=false&inbody=true&returnInbodyStatus=true&sendemail=true"
done
 
echo "Process uploaded files";
curl -s -i --cookie JSESSIONID=$JSESSIONID -X POST "https://$HOST/REST/services/import?import-handler=automation&project=$PROJECT&subject=$SUBJECT&experiment=$SESSION&eventHandler=$EVENTHANDLER&buildPath=$BUILDPATH&configuredResource=_CACHE_&sendemail=true&sessionImport=false&process=true&importFile=false&escapeHtml=false&xsiType=xnat%3AmrSessionData&extract=true"

