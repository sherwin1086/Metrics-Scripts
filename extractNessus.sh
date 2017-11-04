#!/bin/bash

#echo "Extracting WB Nessus external data"
#cat data/nessus/external/* > data/nessus/external/external.out
#rm data/nessus/external/*.csv
#./nessus.pl < data/nessus/external/* > processed_data/nessus/external.out
#echo "Extracting WB Nessus internal data"
#cat data/nessus/internal/* > data/nessus/internal/internal.out
#rm data/nessus/internal/*.csv
#./nessus.pl < data/nessus/internal/* > processed_data/nessus/internal.out
echo "Extracting REDACTED internal"
cat data/nessus/REDACTED/* > data/nessus/REDACTED/REDACTED.out
rm data/nessus/REDACTED/*.csv
./nessus.pl < data/nessus/REDACTED/* > processed_data/qualys/REDACTED.out
echo "Extracting REDACTED internal"
cat data/nessus/REDACTED/* > data/nessus/REDACTED/REDACTED.out
rm data/nessus/REDACTED/*.csv
./nessus.pl < data/nessus/REDACTED/* > processed_data/qualys/REDACTED.out
