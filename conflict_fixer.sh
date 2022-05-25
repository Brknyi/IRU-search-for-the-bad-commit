#!/bin/bash
# Script  for searching the first bad commit where the </ItemData> tag get removed.

# The first commit where the problem not occurred yet. 
good_commit=$1
# The last commit where the problem is still on.
bad_commit=$2

# The use of  git bisect to search for the first bad commit with binary search.
git bisect start

# Mark the last good commit.
git bisect good $good_commit
# Mark the last bad commit.
git bisect bad $bad_commit

# It checks every state of the project with a given script.
# The script checks the number of the opening and closing tags all the .filters file within the project.
git bisect run sh -c '[ "`grep -inrc --include \*.filters  "<ItemData>"`" =  "`grep -inrc --include \*.filters  "</ItemData>"`" ]'
# It will print out the resoult.
# The end of the script with closing the git bisect process.
git bisect reset
