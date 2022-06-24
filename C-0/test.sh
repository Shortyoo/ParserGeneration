#!/bin/sh

for folder in `ls -d */`
do
	echo $folder
	for file in `ls $folder/*/*.in`
	do
		me=`./a.out 1 $file | grep -F -c 'successful'`
		echo "\t$file: $me" ;
	done
done