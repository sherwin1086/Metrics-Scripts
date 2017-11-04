#!/bin/bash

IFS=$'\n'

#curl -H "X-Requested-With: RVM-Utility" -b "qual_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=list&user_login=REDACTED&state=Finished" | awk '/REPORT/ && b {print s; b=0}/\/REPORT/ {s="";next}/[M|m]etrics/ {b=1}{s=s?s RS $0:$0}' >> apiOutput
#curl -H "X-Requested-With: RVM-Utility" -b "turb_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=list&user_login=REDACTED&state=Finished" | awk '/REPORT/ && b {print s; b=0}/\/REPORT/ {s="";next}/[M|m]etrics/ {b=1}{s=s?s RS $0:$0}' >> apiOutput

#Create Array
ID=($(grep ID temp/apiOutput | cut -d '>' -f2 | cut -d '<' -f1))
TITLE=($(grep TITLE temp/apiOutput | cut -d '[' -f3 | cut -d ']' -f1))
#SIZE=($(grep SIZE temp/apiOutput | cut -d '<' -f2 | cut -d '>' -f2))
SIZE=($(grep SIZE temp/apiOutput | cut -d 'B' -f1 | cut -d '>' -f2 | sed 's/ //g'))

echo "Validating file size"
for i in "${!ID[@]}"; do
  echo "${ID[i]} : ${TITLE[i]} : ${SIZE[i]} : $(du -h data/qualys/${TITLE[i]}/${TITLE[i]}.csv | awk '{print $1}')";

#  if [ ${SIZE[i]} = $(du -h data/qualys/${TITLE[i]}/${TITLE[i]}.csv | awk '{print $1}') ]; then
#    echo "Okay"
#  else
#    echo "Not Okay"
#  fi

done
