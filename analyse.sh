#!/bin/bash

SECONDS_IN_DAY=86400
OUTPUT="`pwd`/output"

DATABASE="time_tracker_analysis"

MY_COMPANY="Effectif"
MY_BOOTSTRAPPED_PROJECTS="'Agile Planner', 'Check Satisfacation', 'Quiz the Market'"

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

offset_for_date()
{
    local date="$1"
    date -j -f "%Y-%m-%d" $date "+%s"
}

daily_hours_during_client_job()
{
    local customer="$1"
    execute <<EOF
    COPY
       (SELECT DATE(days.timestamp), customer, project, sum(hours) \
          FROM (
              SELECT generate_series(date '$(first_day "$CUSTOMER")',
                                     date '$(last_day "$CUSTOMER")',
                                     '1 day'
          ) AS timestamp) days
          JOIN logs ON logs.day = DATE(timestamp)
         WHERE customer = '$customer'
            OR project IN ($MY_BOOTSTRAPPED_PROJECTS)
      GROUP BY DATE(days.timestamp), customer, project)
    TO '$OUTPUT/$customer-time-entries.csv' WITH csv HEADER DELIMITER ','
EOF
}

## Main program

IFS="
"

mkdir -p $OUTPUT

for CUSTOMER in `customers`; do
    daily_hours_during_client_job "$CUSTOMER"
done
