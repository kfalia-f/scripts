#! /bin/bash

if [ $# -ne 3 ]
then
	echo "usage ./change_nick.sh [dir] [old nick] [new nick]"
	exit
fi

old_name=$2
new_name=$3

dir="$1/*"

for file in $dir
do
	if [ -f $file ]
	then
		l=$(awk '/\/\*\ \ \ \ \ /' $file | wc -l)
		if [ $l -gt 3 ]
		then
			tmp=$(sed -n '8p' $file)
			dt1=${tmp:14:10}
			tm1=${tmp:25:8}
			tmp=$(sed -n '9p' $file)
			dt2=${tmp:14:10}
			tm2=${tmp:25:8}
			if [ $old_name = $new_name ]
			then
				new_6="/*   By: $new_name <marvin@42.fr>                    +#+  +:+       +#+        */"
				new_8="/*   Created: $dt1 $tm1 by $new_name          #+#    #+#             */"
				new_9="/*   Updated: $dt2 $tm2 by $new_name         ###   ########.fr       */"
			else
				sp=$(( $(expr length $old_name) - $(expr length $new_name) ))
				tmp="                                         "
				new_6="/*   By: $new_name <marvin@42.fr>${tmp:0:20 + sp}+#+  +:+       +#+        */"
				new_8="/*   Created: $dt1 $tm1 by $new_name${tmp:0:10 + sp}#+#    #+#             */"
				new_9="/*   Updated: $dt2 $tm2 by $new_name${tmp:0:9 + sp}###   ########.fr       */"
			fi
			sed -i "6c\\$new_6" $file
			sed -i "8c\\$new_8" $file
			sed -i "9c\\$new_9" $file
			echo $file
		fi
	fi
done
