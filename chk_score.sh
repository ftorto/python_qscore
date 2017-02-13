#!/bin/bash

repo_list = ~/SCM/
repo=$1

cd ${repo_list}${repo};
src_path=src

function get_rate(){

	rate=$(pylint --disable=line-too-long $1 2>/dev/null |tail -2 | grep rated | sed 's/.*at //; s/ .*//; s/\/.*//')
	echo $rate
}

function file_check(){
	f=$1
	sha=$2
	author=$3
	psha=$4

	tmp_file=$(mktemp)
	git show ${sha}:${f} > $tmp_file 2>/dev/null
	rate=$(get_rate $tmp_file)

	git show ${psha}:${f} > $tmp_file 2>/dev/null
	rate_prev=$(get_rate $tmp_file)
	rate_prev=${rate_prev:-0}

	rm $tmp_file

	drate=$(perl -e "print $rate - $rate_prev")
	echo "$sha:$author:$drate:$f"

}

function checker(){
	line=$1
	sha=$(echo $line | cut -d ':' -f1)
	author=$(echo $line | cut -d ':' -f2)
	#psha=$(echo $line | cut -d ':' -f3)
	psha=$(git log ${sha}^ -1 --oneline --format="%h")

	for f in $(git log --simplify-by-decoration -1 --name-only --oneline ${sha} | sed '1d' | egrep 'src.*\.py' | egrep -v 'contrib|test|__init__')
	do
		# For each impacted file

		file_check $f $sha $author $psha &

		while [ $(jobs | wc -l) -ge 4 ] ; do sleep 1 ; done
	done
}

#echo `git log --oneline| wc -l`" commits"

for line in $(git log --oneline --topo-order --all --format="%h:%an")
do
	checker $line
done
