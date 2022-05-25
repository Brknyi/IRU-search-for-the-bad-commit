#!/bin/bash

good_commit=$1
bad_commit=$2

git bisect start > logs.txt 
git bisect good $good_commit >> logs.txt
git bisect bad $bad_commit >> logs.txt
git bisect run sh -c '[ "`grep -inrc --include \*.filters  "<ItemData>"`" =  "`grep -inrc --include \*.filters  "</ItemData>"`" ]' >> logs.txt
if [ "`grep "is the first bad commit" logs.txt`" ]
then
	echo "The ID of the first bad commit: " `awk '/is the first bad commit/ {print $1}' logs.txt`	
else
	echo "A problem is occurred. The log of the script: "
	cat logs.txt
fi
git bisect reset >> logs.txt 2>&1
rm logs.txt
