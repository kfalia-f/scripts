#!/bin/bash

if [ $# -ne 1 ] || [ $1 = "-h" ]
then
  echo "usage: $0 [file name]"
  exit
fi

if [ ! -e $1 ]
then
  echo "$0: no such file: $1"
  exit
fi

file_name=$1
file_name_new="$file_name-new"

num_arr=$(cat -n $file_name | grep "enforce_valid_polygon" | awk '{ print $1 }')
str_num=$(cat -n $file_name | wc -l)
iter=0
prev=1

num=$(echo $num_arr | sed 's/ /\n/g' | wc -l)
echo -e "$num \n$num_arr"

for i in $num_arr
do
  tmp=$(( $i - 1 ))
  if [ $prev -ne $i ]
  then
    sed -n "$prev,${tmp}p" $file_name | sed "$(( $tmp - $prev + 1 )) s/,$//" >> $file_name_new
  fi
  echo "prev = $prev, i = $i"
  (( iter++ ))
  echo "$iter of $num"
done

sed -n "$prev,${str_num}p" $file_name >> $file_name_new

mv $file_name_new $file_name

exit
