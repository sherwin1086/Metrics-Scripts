REDACTED#!/bin/bash

IFS=$'\n'
date=$(date +%Y%m%d)
dataArchive1="data/archive/data-archive-$date.tar.gz"
dataArchive2="processed_data/archive/processedData-archive-$date.tar.gz"

#Qualys Auth
echo -e "Step 1: Establishing Qualys session\n"
sh sessionAuth.sh

echo -e "\n\nStep 2: Fetching report list and building arrays\n"
rm temp/apiOutput
curl -H "X-Requested-With: RVM-Utility" -b "temp/turb_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=list&user_login=REDACTED&state=Finished" | awk '/REPORT/ && b {print s; b=0}/\/REPORT/ {s="";next}/[M|m]etrics/ {b=1}{s=s?s RS $0:$0}' >> temp/apiOutput
curl -H "X-Requested-With: RVM-Utility" -b "temp/qual_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=list&state=Finished" | awk '/REPORT/ && b {print s; b=0}/\/REPORT/ {s="";next}/[M|m]etrics/ {b=1}{s=s?s RS $0:$0}' >> temp/apiOutput

#Create Array
ID=($(grep -i ID temp/apiOutput | cut -d '>' -f2 | cut -d '<' -f1))
TITLE=($(grep -i TITLE temp/apiOutput | cut -d '[' -f3 | cut -d ']' -f1))
#SIZE=($(grep -i SIZE temp/apiOutput | cut -d '<' -f2 | cut -d '>' -f2))
SIZE=($(grep -i SIZE temp/apiOutput | cut -d 'B' -f1 | cut -d '>' -f2 | sed 's/ //g'))
DATE=($(grep -i LAUNCH_DATETIME temp/apiOutput | cut -d '>' -f2 | cut -d 'T' -f1))
TIME=($(grep -i LAUNCH_DATETIME temp/apiOutput | cut -d '>' -f2 | cut -d 'T' -f2 | cut -d 'Z' -f1))

echo -e "\n\nStep 3: Archiving old reports\n"
tar -czf $dataArchive1 data/nessus data/qualys
rm -r data/nessus/*
rm -r data/qualys/*
tar -czf $dataArchive2 processed_data/*.txt processed_data/nessus processed_data/qualys processed_data/topTen
rm processed_data/*.txt
rm -r processed_data/nessus/*
rm -r processed_data/qualys/*
rm -r processed_data/topTen/*

echo -e "\n\nStep 4: Checking directories...\n"
for i in "${!ID[@]}"; do
#  if [ ! -d data/qualys/${TITLE[i]} ]; then
    mkdir -p data/qualys/${TITLE[i]}
#  fi
done
mkdir -p data/nessus/external
mkdir -p data/nessus/internal
mkdir -p data/nessus/REDACTED
mkdir -p data/nessus/REDACTED

echo -e "Step 5: Downloading reports from Qualys\n"
for i in "${!ID[@]}"; do
  if [[ ${TITLE[i]} =~ .*REDACTED.* ]]; then
    echo "Downloading ${TITLE[i]} Report"
    curl -H "X-Requested-With: RVM-Utility" -b "temp/turb_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=fetch&id=${ID[i]}" >> data/qualys/${TITLE[i]}/${TITLE[i]}.csv;
  else
    echo "Downloading ${TITLE[i]} Report"
    curl -H "X-Requested-With: RVM-Utility" -b "temp/qual_cookie.txt" "https://qualysapi.qualys.com/api/2.0/fo/report/" -d "action=fetch&id=${ID[i]}" >> data/qualys/${TITLE[i]}/${TITLE[i]}.csv
    echo;
  fi
done

echo -e "Step 6: Logging out of Qualys\n"
curl -H "X-Requested-With: RVM Utility" -b "temp/qual_cookie.txt" -d "action=logout" "https://qualysapi.qualys.com/api/2.0/fo/session/"
rm temp/qual_cookie.txt
curl -H "X-Requested-With: RVM Utility" -b "temp/turb_cookie.txt" -d "action=logout" "https://qualysapi.qualys.com/api/2.0/fo/session/"
rm temp/turb_cookie.txt

#Top Ten Script
#echo -e "Step 7: Top Ten Vulnerabilities"
#sh topTen2.sh
