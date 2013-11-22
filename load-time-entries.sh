#!/bin/sh

DATABASE=time_tracker_analysis
CSV_FILE=$1

## Functions

usage()
{
    echo "Usage: $(basename $0) <time-entries.csv>" 1>&2
    exit 1
}

execute()
{
    psql -a $DATABASE $*
}

## Main program

[ -z "$CSV_FILE" ] && usage

execute -f schema.sql
execute <<-EOF
COPY logs (day, customer, project, service, person, note, hours, revenue, locked)
FROM '$CSV_FILE'
WITH CSV HEADER DELIMITER ';'
EOF
