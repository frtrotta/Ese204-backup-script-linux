#!/bin/bash

source_dir=$1
destination_dir=$2
backup_type=$3

if [ -z ${source_dir} ] || [ -z ${destination_dir} ] || [ -z ${backup_type} ]
then
	echo 'ERROR: missing parameter(s)' >&2
	echo "Sintax: $0 <source_dir> <destination_dir> <backup_type>" >&2
	exit 1
fi

temp_file=`mktemp` # This fill hold STDERR messages for later use
reference_date=`./backup_reference_date.sh ${destination_dir} ${backup_type} 2>${temp_file}`
exit_code=$?

case "${exit_code}" in
	'0')
		date_string=`date +%Y%m%d%H%M%S`
		backup_dir="backup${date_string}${backup_type}"
		echo "Destination directory is ${destination_dir}/${backup_dir}"
		mkdir "${destination_dir}/${backup_dir}"
		find ${source_dir} -type f -newermt "${reference_date}" -print -exec cp --parent '{}' ${destination_dir}/${backup_dir} \;
		echo "Backup completed in ${destination_dir}/${backup_dir}"
		;;
	'2' | '3' | '10' | '11')
		< ${temp_file}
		;;
	*)
		echo 'ERROR: unexpected exit code from reference_date.sh' >&2
		echo "Exit code: ${exit_code}" >&2
		cat ${temp_file} >&2
		exit 30
		;;
esac;

rm ${temp_file}
exit ${exit_code}
