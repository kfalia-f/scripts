#! /bin/bash

#sed -i '1,12d' file

for dir in $@
do
	for file in $dir/*
	do
		if [ -f $file ]
		then
			l=$(awk '/\/\*\ \ \ \ \ /' $file | wc -l)
			if [ $l -gt 3 ]
			then
				echo $file
				sed -i '1,12d' $file
			fi
		fi
	done
done
