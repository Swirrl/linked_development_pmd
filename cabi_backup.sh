#!/bin/bash
#
# First we source the backup-helpers.sh file to import the helper
# functions and environment variables.
#
# In particular backup-helpers exports the following useful variables:
#
# $CURRENT_TIME : The current system time in seconds since the epoch.
# $XSD_DATESTR  : The current system time in XSD date string ISO 8601 format.
# $DATESTR      : The current system time in PMD format YYYYMMDDSS

source backup-helpers.sh

# The script must set the following variables in order for the sourced
# functions to work.
#
# LOCAL_BACKUP_DIR : The directory in which to store local backups
#                    prior to upload (and 2 weeks thereafter).
#
# S3_BUCKET        : The URL of the remote S3 bucket.
#
# BASE_ENDPOINT    : The root URL path for the SPARQL endpoint
#
# DATA_ENDPOINT    : The endpoint for where to get datadumps
#
# UPDATE_ENDPOINT : The endpoint for where to send SPARQL updates to,
#                   in order to set the modified timestamp on the
#                   dataset metadata.

LOCAL_BACKUP_DIR=/home/cabi-crawler/backups
S3_BUCKET=s3://linkeddev-dumps
BASE_ENDPOINT=http://sparql3.publishmydata.com/linkeddev
DATA_ENDPOINT=$BASE_ENDPOINT/data
UPDATE_ENDPOINT=$BASE_ENDPOINT/update

# Here we set the filenames for the local files and those which will
# be uploaded to s3.  These names MUST conform to PMD naming
# conventions i.e. they must be of the following form:
#
#      <resource_type>_data_<slug>_<YYmmdd>
#
# Additionally, if there are any /'s in the slug, then they need to be
# replaced with |'s.

ELDIS_DATA="dataset_data_eldis_$DATESTR.nt"
R4D_DATA="dataset_data_r4d_$DATESTR.nt"

# Next we set some variables for the graphs we wish to backup.

ELDIS_GRAPH="http://linked-development.org/graph/eldis"
R4D_GRAPH="http://linked-development.org/graph/r4d"

################################################################################
# Start Backup
################################################################################

# First fetch the triples from the graph and store them locally in the
# files named above.

fetch_ntriples $ELDIS_DATA $ELDIS_GRAPH
fetch_ntriples $R4D_DATA $R4D_GRAPH

# Upload the downloaded files to S3.

upload_to_s3 $ELDIS_DATA
upload_to_s3 $R4D_DATA

# Set the modified date timestamp so that PMD can find the next graph.

set_modified_date $ELDIS_GRAPH
set_modified_date $R4D_GRAPH

# Remove any local backups (older than 14 days old)

remove_old_backups

echo "$DATESTR Backup Complete."
