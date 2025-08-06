#!/usr/bin/env zsh
## AD22 “Practical SQL, A Beginner’s Guide to Storytelling with Data” 2nd Ed, page 19.
##   Anthony DeBarros, January 2022, 392 pp.  ISBN-13: 978-1-7185-0107-2
##

# SET OPTIONS
set -o errexit
set -o nounset

#DEFINE FUNCTIONS

function tm_nw_str {
   printf -v DT_STR '%s' "$(date '+%Y-%m-%dT%H:%M:%S%:%z')" 
} 

function wrt_msg {
# Write a message to stdout, then underline that message.
## ${1}  delimited to catch the eye
## ${2}  a short message
    tm_nw_str  # Obtain datatime string
    printf -v STR '%s  %s --  %s  %s' "${1}" "${DT_STR}" "${2}" "${1}"
    printf '\n%s\n' "${STR}"
    STR_LNGTH=${#STR}
    printf '\x2D%.0s' $(eval echo {1..${STR_LNGTH}})
    echo
} 

#MAIN


wrt_msg '***' 'Listing ad22-02-01 CREATE DATABASE analysis;'
psql <<EOF
CREATE DATABASE "AD22";  -- Double quotes so name is in uppercase.
EOF

wrt_msg '---' 'echo $?  --  zero means "All is well."'
echo $?

# https://www.postgresql.org/docs/current/sql-createtable.html
wrt_msg '---' 'CREATE the table if does not exist. Then INSERT data.'
psql --dbname AD22 --echo-all --echo-queries <<EOF
CREATE TABLE IF NOT EXISTS teachers
(
    id bigserial,
    first_name varchar(25),
    last_name varchar(50),
    school varchar(50),
    hire_date date,
    salary numeric
);
-- Listing 2-3 Inserting data into the teachers table

INSERT INTO teachers (first_name, last_name, school, hire_date, salary)
VALUES ('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),
       ('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000),
       ('Samuel', 'Cole', 'Myers Middle School', '2005-08-01', 43500),
       ('Samantha', 'Bush', 'Myers Middle School', '2011-10-30', 36200),
       ('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
       ('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);
EOF

wrt_msg '---' 'Validate table structure and the INSERTed data.'
psql --dbname AD22 --echo-all \
  --command '\d+ teachers' \
  --command 'Table teachers;'