#!/bin/bash

source_dir=$1
destination_dir=$2
reference_date_string=$3

if [ -z ${reference_date_string} ] || [ -z ${source_dir} ] || [ -z ${destination_dir} ]
then
	echo pippo >&2
	exit 1
fi

echo ">== sono in ${source_dir}"
for fname in `ls ${source_dir}`
do
	if [ -f "$fname" ]
	then
		# Si tratta di un file
		fdate=`stat -c %y $fname`
		fdate_string=`date --date="$fdate" +%Y%m%d%H%M%S`
		if [ "${reference_date_string}" \< "${fdate_string}" ]
		then
			echo copio $fname in ${destination_dir}
			# cp $fname ${destination_dir}
			
		fi
	else
		if [ -d "$fname" ]
		then
			# Si tratta di una directory
			echo "Creata directory ${destination_dir}/${fname}"
			# mkdir ${destination_dir}/${fname}
			# if [ $? -eq 0 ]
			# then
				 $0 ${source_dir}/${fname} ${destination_dir}/${fname} ${reference_date_string} 
			# else
				# echo "Unable to create ${fname} directory in ${destination_dir}" > &2
			# fi
		fi
	fi
done
echo ">== FINITO in ${source_dir}"
