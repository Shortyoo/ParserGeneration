#!/bin/sh

LightRed='\033[1;31m';
LightGray='\033[0;37m';

echo "\tWe expect ${LightRed}1${LightGray} on every result."

for folder in `ls -d */`
do
	echo $folder
	for file in `ls ${folder}/SUCCEEDING/`
	do
		me=`./a.out 1 $folder/SUCCEEDING/$file | grep -F -c 'successful'`
		echo "\t\t/SUCCEEDING/$file: $me" ;
	done
	for file in `ls ${folder}/FAILING/`
	do
		me=`./a.out 1 $folder/FAILING/$file | grep -F -c 'ERROR syntax error'`
		echo "\t\t/FAILING/$file: $me" ;
	done
done

echo ""
echo "${LightRed}Unexpected results? Did you run 'make'?";