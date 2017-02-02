#!/bin/bash

repo=$1

result_file=~/result_chkscore_$repo.txt

cd $repo;
src_path=src

function checker(){
	line=$1
	sha=${line%:*}
	git checkout -q $sha
	raw_rate=$(pylint $src_path --ignore=test 2>/dev/null | tail -2 | grep rated | sed 's/.*at //; s/ .*//')
	rate=${raw_rate%/*}
	echo "$repo:$line:$rate" >> $result_file
	echo "$line:$rate"	
}

echo `git log --oneline| wc -l `" commits"

for line in $(git log --reverse --oneline --topo-order --all --format="%h:%cn-%p")
do
	checker $line
done

