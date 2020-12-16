#!/bin/bash
python expr.py 
rm -f results.txt 
while read p; do
  echo "$p" | ./calc >> results.txt
done <in.txt
DIFF=$(diff results.txt exp.txt) 
if [ "$DIFF" == "" ] 
then
    echo "All calculations are correct SUCCESS!"
    exit
fi
echo "FAILED"