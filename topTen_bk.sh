#!/bin/bash

#csvquote $CSVPATH | awk -F"," '$23 ~ 10' | cut -d ',' -f 8 | sort | uniq -c | sort -rn | head

dirName=($(ls data/qualys/*/*.csv | cut -d '/' -f3))

for i in "${!dirName[@]}"; do
  echo "Running Top Ten for ${dirName[i]}"
  csvquote data/qualys/${dirName[i]}/*.csv | awk -F"," '$24 ~ 10' | cut -d ',' -f 9 | sort | uniq -c | sort -rn | head -n 15 > processed_data/topTen/${dirName[i]}_TopTen_temp.csv;

  total_lines=$(csvquote data/qualys/${dirName[i]}/*.csv | awk -F"," '$24 ~ 10' | wc -l)
  while read -r line; do
    count=$(echo $line | cut -f1 -d " ");
    percent=$(echo "scale=4; ($count/$total_lines)*100" | bc);
    echo "$line -- $percent%";
  done < processed_data/topTen/${dirName[i]}_TopTen_temp.csv > processed_data/topTen/${dirName[i]}_TopTen.csv;

  rm processed_data/topTen/${dirName[i]}_TopTen_temp.csv;
  echo -e "${dirName[i]} Top Ten complete \n\n "
done

echo "Combining Top Ten Reports"
for i in processed_data/topTen/*.csv; do
  echo $i | cut -d'/' -f3 >> processed_data/topTen/TopTen.csv;
  cat $i >> processed_data/topTen/TopTen.csv;
  echo -e " \n " >> processed_data/topTen/TopTen.csv;
done
