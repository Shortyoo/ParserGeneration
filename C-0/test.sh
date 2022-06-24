#!/bin/sh

LightRed='\033[1;31m';
LightGray='\033[0;37m';

for folder in `ls -d */`
do
	echo $folder
	echo "\tWe expect ${LightRed}1${LightGray} here."
	for file in `ls ${folder}/SUCCEEDING/`
	do
		me=`./a.out 1 $folder/SUCCEEDING/$file | grep -F -c 'successful'`
		echo "\t\t$file: $me" ;
	done
	echo "\tWe expect ${LightRed}0${LightGray} here."
	for file in `ls ${folder}/FAILING/`
	do
		me=`./a.out 1 $folder/FAILING/$file | grep -F -c 'successful'`
		echo "\t\t$file: $me" ;
	done
done

echo ""
echo "${LightRed}Unexpected results? Did you run 'make'?";