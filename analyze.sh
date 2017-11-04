#!/bin/bash

echo "Creating lists of unique WB IP addresses seen by Nessus"
cd processed_data/nessus
echo "      external IPs..."
cut -d"," -f 2 < external.out | sort | uniq > external_ips.txt
echo "      internal IPs..."
cut -d"," -f 2 < internal.out | sort | uniq > internal_ips.txt
echo "Creating lists of unique WB IP addresses seen by Qualys"
cd ../qualys
echo "      external IPs..."
cut -d"," -f 2 < ICS.WB-EXT_Metrics.out | sort | uniq > ../wb_external_ips.txt
echo "      internal IPs..."
cut -d"," -f 2 < ICS.WB.INT_Metrics.out | sort | uniq > ../wb_internal_ips.txt
echo "Finding duplicated IPs (i.e. IPs seen by both Qualys and Nessus)"
echo "      external IPs..."
grep -Fx -f ../nessus/external_ips.txt ../wb_external_ips.txt > ../nessus/external_dupes.txt
echo "      internal IPs..."
grep -Fx -f ../nessus/internal_ips.txt ../wb_internal_ips.txt > ../nessus/internal_dupes.txt
cd ../nessus
echo "De-duplicating Nessus results (i.e. removing findings duplicated in the Qualys results)"
cp internal.out internal_deduped.out
cp external.out external_deduped.out
echo "      external IPs..."
cat external_dupes.txt | sed -e "s/^/'\/,/g" -e "s/$/,\/d'/g" -e 's/\./\\./g' | xargs -I PATTERN sed -i- PATTERN external_deduped.out
echo "      internal IPs..."
cat internal_dupes.txt | sed -e "s/^/'\/,/g" -e "s/$/,\/d'/g" -e 's/\./\\./g' | xargs -I PATTERN sed -i- PATTERN internal_deduped.out
rm -f external_deduped.out-
rm -f internal_deduped.out-
echo "Appending Nessus results to Qualys results"
cat ../qualys/ICS.WB.INT_Metrics.out internal_deduped.out > ../qualys/WBInternal.out
cat ../qualys/ICS.WB-EXT_Metrics.out external_deduped.out > ../qualys/WBExternal.out
cd ../qualys
#############################
#############################

filename=($(ls | rev | cut -d'.' -f2- | rev))

echo "Counting devices for each data category"
for i in "${!filename[@]}"; do
  cut -d"," -f2 < ${filename[i]}.out | sort | uniq | wc -l > ${filename[i]}Devices.txt
done
#############################
echo "Developing general statistics:"
for i in "${!filename[@]}"; do
  echo "      ${filename[i]} IPs..."
  ../../stats.pl ${filename[i]}.out ${filename[i]}MonthlyByCrit.csv
done
#############################
echo "Developing longevity statistics:"
for i in "${!filename[@]}"; do
  echo "      ${filename[i]} IPs..."
  ../../longevity.pl ${filename[i]}.out ${filename[i]}VulnLongevity.csv
done
