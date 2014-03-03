#!/bin/bash

DATESTR=$(date +"%Y%m%d%H%M%S")
LOCAL_BACKUP_DIR=/home/cabi-crawler/backups

BASE_ENDPOINT=http://sparql3.publishmydata.com/linkeddev
DATA_ENDPOINT=$BASE_ENDPOINT/data
UPDATE_ENDPOINT=$BASE_ENDPOINT/update

function fetch_ntriples() {
    FILE_NAME="$LOCAL_BACKUP_DIR/$1"
    GRAPH_URI=$2

    SOURCE_URI=$DATA_ENDPOINT?graph=$GRAPH_URI

    curl -s -H "Accept:text/plain" -f -o $FILE_NAME $SOURCE_URI
    CURL_STATUS=$?

    if [ $CURL_STATUS -ne 0 ]; then
        echo "Failed to fetch URL with curl: $SOURCE_URI"
        echo "Backup Failed to Complete."
        exit 1
    fi

    gzip $FILE_NAME
    echo "Downloaded & Gzipped triples to $FILE_NAME"
}

function upload_to_s3() {
    FNAME=$1
    FILE_NAME="$LOCAL_BACKUP_DIR/$FNAME.gz"
    s3cmd put -P $FILE_NAME s3://linkeddev-dumps
    S3_STATUS=$?
    if [ $S3_STATUS -ne 0 ]; then
        echo "Failed to put backup on S3"
        echo "Backup Failed to Complete."
        exit 2
    fi
    echo "Copied $FILE_NAME to S3"
}

# For backup purposes
function set_modified_date() {
    GRAPH_SLUG=$1
    query=`printf 'WITH <http://linked-development.org/graph/%s/metadata>
                        DELETE { ?ds <http://purl.org/dc/terms/modified> ?mod }
                        INSERT { ?ds <http://purl.org/dc/terms/modified> "%s"^^<http://www.w3.org/2001/XMLSchema#dateTime> }
                        WHERE {
                            GRAPH <http://linked-development.org/graph/%s/metadata> {
                                ?ds a <http://publishmydata.com/def/dataset#Dataset> .
                                OPTIONAL { ?ds <http://purl.org/dc/terms/modified> ?mod }
                            }
                        }' $GRAPH_SLUG $DATESTR $GRAPH_SLUG `

    curl -s -f -d "request=$query" $UPDATE_ENDPOINT > /dev/null
    CURL_STATUS=$?

    if [ $CURL_STATUS -ne 0 ]; then
        echo "Failed to update modified date"
        echo "Backup Failed to Complete."
        exit 3
    fi
    echo "Modification Date Set for $GRAPH_SLUG to $DATESTR"
}

function remove_backup() {
    FNAME=$1
    rm $FNAME
    echo "Removed old local backup: $FNAME"
}

export -f remove_backup # export the function so we can use it with find

function remove_old_backups() {
    # NOTE the crazy syntax for calling an exported function and
    # passing an arg to find -exec.
    find $LOCAL_BACKUP_DIR -mtime +14 -exec bash -c 'remove_backup "$0"' {} \;
}

ELDIS_DATA="eldis_data_$DATESTR.nt"
R4D_DATA="r4d_data_$DATESTR.nt"

fetch_ntriples $ELDIS_DATA  "http%3A%2F%2Flinked-development.org%2Fgraph%2Feldis"
fetch_ntriples $R4D_DATA "http%3A%2F%2Flinked-development.org%2Fgraph%2Fr4d"

upload_to_s3 $ELDIS_DATA
upload_to_s3 $R4D_DATA

set_modified_date "eldis"
set_modified_date "r4d"

remove_old_backups

echo "$DATESTR Backup Complete."
