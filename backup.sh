#!/bin/bash

source_dir=$1
destination_dir=$2
backup_type=$3

if [ -z ${source_dir} ] || [ -z ${destination_dir} ] || [ -z ${backup_type} ]
then
	echo 'ERROR: missing parameter(s)' > /dev/stderr
	echo "Syntax: $0 <source_dir> <destination_dir> <backup_type>" > /dev/stderr
	exit 1
fi

# Directory che contiene questo e gli altri script necessari
script_dir=$(dirname $0)

# Ottengo il nome di un file temporaneo. In esso salverò l'eventuale errore
# che otterrò dall'invocazione di backup_reference_date_string.sh, in modo da poterlo
# restituire a chi invoca questo script
temp_file=$(mktemp)

# Ottengo la stringa con la data di riferimento
# Nell'invocare lo script per ottenere la data di riferimento, redirigo stderr sul file
# temporaneo, di cui ho prima ottenuto il nome. In questo modo, in caso di errore potrò
# riproporre il messaggio comunicato direttamente a chi invoca questo script.
reference_date_string=$(${script_dir}/backup_reference_date_string.sh ${destination_dir} ${backup_type} 2> ${temp_file})
exit_code=$?

if [ ${exit_code} -eq 0 ]
then
	# Stringa con la data di riferimento ottenuta
	
	# Creo la stringa con la data corrente
	current_date_string=$(date +%Y%m%d%H%M%S)
	
	# Creo directory di backup
	backup_dir="${destination_dir}/backup${current_date_string}${backup_type}"
	
	mkdir ${backup_dir}
	if [ $? -eq 0 ]
	then
		
		# Invoco lo script
		${script_dir}/backup_helper.sh ${source_dir} ${backup_dir} ${reference_date_string}
		exit_code=$?
		if [ ${exit_code} -ne 0 ]
		then
			rm -fr ${backup_dir}
		fi
	else
		echo "ERROR: Unable to create ${backup_dir} directory in ${destination_dir}" > /dev/stderr
		echo 'Exiting...'  > /dev/stderr
		exit 100
	fi
	
else
	# Si è verificato un errore nell'ottenre la data di riferimento
	# Stampo il medesimo testo dell'errore che ho ricevuto
	cat ${temp_file} > /dev/stderr
	exit ${exit_code}
fi

rm ${temp_file}
