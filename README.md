# XNAT_REST_API_scripts
## Contains scripts that can be used to download or upload information from intraDB.

- These scripts expect $HOME/.intradb.curl.conf to contain "-u myUserID:myPassword"
- Use `chmod 600 $HOME/.intradb.curl.conf` to prevent bad stuff

### Get intraDB jsessionID (permissions to interact with database)
* Script refresh_intraDB_jsessionID.sh will return JSESSIONID to use with REST API
* run command:
* JSESSIONID=$( $PROJECTS/XNAT_REST_API_scripts/refresh_intraDB_jsessionID.sh -j $JSESSIONID )

### Get list of Session IDs in a specific project
* Script get_intraDB_list_SessionIDs.sh returns six columns about each Session:
* SubjectID,SessionID,Project,Scanner,Date,Operator
* run command:
* $PROJECTS/XNAT_REST_API_scripts/get_SessionID_list.sh -j $JSESSIONID -p $PROJECT

### Check if PsychoPy files for that session are present in intraDB
* Script get_linked_data_list.sh to get list of LINKED_DATA files associated with session (scan-level and session-level)
* $PROJECTS/XNAT_REST_API_scripts/get_linked_data_list.sh -j $JSESSIONID -p $PROJECT -s $SUBJECT -e $SESSION


### Check if PsychoPy files for that session are present in Box


### Prepare PsychoPy files from Box for intraDB linked data uploader
* flatten directory structure (but don't allow duplicates to overwrite each other)
* verify that filenames match expected pattern

### Uploading PsychoPy files from local directory (or mapped Box drive) to intraDB


### Upload PsychoPy files to session in intraDB


### Move (or delete) PsychoPy files that have been successfully uploaded


### Find usability of scans by scan name

