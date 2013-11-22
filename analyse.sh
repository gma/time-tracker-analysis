#!/bin/bash

SECONDS_IN_DAY=86400
OUTPUT="`pwd`/output"

DATABASE="time_tracker_analysis"

MY_COMPANY="Effectif"
MY_BOOTSTRAPPED_PROJECTS="'Agile Planner', 'Check Satisfacation', 'Quiz the Market', 'Nichelator', 'Project Make Money', 'Wiki Search', 'Challenge 2010'"

## Functions

usage()
{
    echo "Usage: $(basename $0)" 1>&2
    exit 1
}

execute()
{
    psql -d $DATABASE -A -t
}

customers()
{
    echo "SELECT DISTINCT customer FROM logs WHERE customer NOT IN ('', 'Effectif')" | execute
}

first_day()
{
    local customer="$1"
    echo "SELECT MIN(day) FROM logs WHERE customer = '$customer'" | execute
}

last_day()
{
    local customer="$1"
    echo "SELECT MAX(day) FROM logs WHERE customer = '$customer'" | execute
}

daily_hours_during_client_job()
{
    local customer="$1"
    local basename=$(echo $customer | tr A-Z a-z | sed 's/ /-/g')
    execute <<EOF
        COPY
           (SELECT DATE(days.timestamp), customer, sum(hours)
              FROM (
                  SELECT generate_series(date '$(first_day "$CUSTOMER")',
                                         date '$(last_day "$CUSTOMER")',
                                         '1 day'
              ) AS timestamp) days
   FULL OUTER JOIN logs ON DATE(timestamp) = logs.day
          GROUP BY DATE(days.timestamp), customer
          HAVING customer = '$customer' OR sum(hours) IS NULL
          ORDER BY DATE(days.timestamp) ASC
          )
        TO '$OUTPUT/$basename-time-entries.csv' WITH csv DELIMITER ','
EOF
}

## Main program

IFS="
"

mkdir -p $OUTPUT

for CUSTOMER in `customers`; do
    daily_hours_during_client_job "$CUSTOMER"
done
