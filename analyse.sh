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
    psql -d $DATABASE -A -t -c $1
}

customers()
{
    execute "SELECT DISTINCT customer FROM logs WHERE customer NOT IN ('', 'Effectif')"
}

first_day()
{
    local customer="$1"
    execute "SELECT MIN(day) FROM logs WHERE customer = '$customer'"
}

last_day()
{
    local customer="$1"
    execute "SELECT MAX(day) FROM logs WHERE customer = '$customer'"
}

daily_hours_during_client_job()
{
    local customer="$1"
    local basename=$(echo $customer | tr A-Z a-z | sed 's/ /-/g')
    local sql
    read -r -d '' sql <<EOF
        COPY
           (SELECT DATE(days.timestamp), customer, sum(hours)
              FROM
                  (
                    SELECT generate_series(date '$(first_day "$CUSTOMER")',
                                           date '$(last_day "$CUSTOMER")',
                                           '1 day') AS timestamp
                  ) days
              LEFT OUTER JOIN
                  (
                    SELECT day, customer, hours FROM logs
                     WHERE customer = '$customer'
                        OR project IN ($MY_BOOTSTRAPPED_PROJECTS)
                  ) customer_logs
                ON DATE(timestamp) = customer_logs.day
          GROUP BY DATE(days.timestamp), customer_logs.customer
          ORDER BY DATE(days.timestamp) ASC
          )
        TO '$OUTPUT/$basename-time-entries.csv' WITH csv DELIMITER ','
EOF
    execute "$(echo $sql)"
}

## Main program

IFS="
"

mkdir -p $OUTPUT

for CUSTOMER in `customers`; do
    daily_hours_during_client_job "$CUSTOMER"
done
