#!/bin/bash

source_dir=$1
destination_dir=$2
reference_date_string=$3

if [ -z ${source_dir} ] || [ -z ${destination_dir} ] || [ -z ${reference_date_string} ]
then
	echo 'ERROR: missing parameter(s)' > /dev/stderr
	echo "Syntax: $0 <source_dir> <destination_dir> <reference_date_string>" > /dev/stderr
	exit 1
fi

for fname in `ls ${source_dir}`
do
	relative_fname="${source_dir}/${fname}"
	# relative_fname è necessario poiché la directory corrente non viene mai modificata.
	# Per questa ragione relative fname memorizza il percorso realtivo dell'elemento (sia
	# esso file o directory) rispetto alla cartella corrente
	
	if [ -f "${relative_fname}" ]
	then
		# Si tratta di un file
		fdate=`stat -c %y $relative_fname`
		fdate_string=`date --date="$fdate" +%Y%m%d%H%M%S`
		if [ "${reference_date_string}" \< "${fdate_string}" ]
		then
			echo "Copio ${relative_fname} in ${destination_dir}"
			cp ${relative_fname} ${destination_dir}
		fi
	else
		if [ -d "${relative_fname}" ]
		then
			# Si tratta di una directory
			
			# Creo la directory di destinazione
			mkdir ${destination_dir}/${fname}
			
			if [ $? -eq 0 ]
			then
				# Chiamata ricorsiva
				# Invoco lo script stesso con la sottodirectory sorgente appena individuata
				$0 ${relative_fname} ${destination_dir}/${fname} ${reference_date_string}
				
			else
				echo "ERROR: Unable to create ${fname} directory in ${destination_dir}" > /dev/stderr
				echo 'Exiting...'  > /dev/stderr
				exit 3
			fi
		else
			echo "ERROR: unable to identify ${relative_fname} (is it a file o a directory?)" > /dev/stderr
			echo 'Exiting...'  > /dev/stderr
			exit 2
		fi
	fi
done
