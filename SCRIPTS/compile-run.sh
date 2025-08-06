#!/usr/bin/env zsh
# Compile and run COBOL on a RHEL instance with IBM COBOL for Linux for x86.


#SET OPTIONS
set -o errexit
set -o nounset

#DEFINE FUNCTIONS

function tm_nw_str {
# ISO-8601 datetime with timezone offest.
  printf -v DT_STR '%s' "$(date '+%Y-%m-%dT%H:%M:%S%:%z')" 
} 

function wrt_msg {
# Write a message to stdout, then underline the message.
## ${1}  delimiter to catch the eye
## ${2}  the message
    tm_nw_str  # Obtain datatime with timezone offset string.
    printf -v STR '%s  %s --  %s  %s' "${1}" "${DT_STR}" "${2}" "${1}"
    printf '\n%s\n' "${STR}"
    STR_LNGTH=${#STR}
    printf -- '-%.0s' $(eval echo {1..${STR_LNGTH}})
    echo
} 

#SET DEFAULTS
REMOTE=${2:-ic4lx86}

#MAIN

wrt_msg '***' "001  Compile and execute ${1} on the remote RHEL machine."
strng='sftp '
strng+="${REMOTE}"
strng+=':/home/virtuser/COBOL <<< "put ../COBOL/'
strng+="${1}"
strng+='.cobol"'
printf '>>>%s<<<\n\n' ${strng}
# sftp ic4lx86:/home/virtuser/COBOL <<< "put ../COBOL/${1}.cobol"
bash -c "${strng}"

wrt_msg '***' '002  Compile and link-edit to PGSQL ecpg.'
strng='cob2_pgsql /home/virtuser/COBOL/'
strng+="${1}"
strng+='.cobol -o '
strng+="${1}"
ssh_cmd="ssh ${REMOTE} ${strng}"
printf '>>>%s<<<\n\n' "${ssh_cmd}"
bash -c "${ssh_cmd}"

wrt_msg '***' '003  Execute the COBOL program to display results from PGSQL.'
strng='./'
strng+="${1}"
# printf '>>>%s<<<\n\n' ${strng}
# ssh ic4lx86 "${strng}"
ssh_cmd="ssh ${REMOTE} ${strng}"
printf '>>>%s<<<\n\n' "${ssh_cmd}"
bash -c "${ssh_cmd}"

wrt_msg '***' '004  Validate the COBOL PGSQL results with psql expression equivalent to the COBOL program.'
printf '>>>%s<<<\n\n' $'psql --dbname AD22 --command "SELECT CONCAT(first_name, \' \', last_name) AS emp_names FROM teachers;"'
psql --dbname AD22 --command "SELECT CONCAT(first_name, ' ', last_name) AS emp_names FROM teachers;"