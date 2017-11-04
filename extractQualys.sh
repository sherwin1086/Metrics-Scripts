#!/bin/bash

dirName=($(ls data/qualys/*/*.csv | cut -d '/' -f3))

for i in "${!dirName[@]}"; do
  echo "Extracting ${dirName[i]} data"
  ./qualys.pl < data/qualys/${dirName[i]}/* > processed_data/qualys/${dirName[i]}.out
done
