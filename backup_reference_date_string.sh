#!/bin/bash

destination_dir=$1
backup_type=$2

# Check whether all parameters are defined
if [ -z ${destination_dir} -o -z ${backup_type} ]
then
	echo 'ERROR: missing parameter(s)' >&2
	echo "Sintax: $0 <destination_dir> <backup_type>" >&2
	exit 1
fi

# Check whether destination_dir is a valid directory
if [ ! -d "${destination_dir}" ]
then
	echo 'ERROR: wrong directory' >&2
	echo "${destination_dir} does not seem to be a valid directory" >&2
	exit 2
fi

case "${backup_type}" in
	'completo')
		dname='backup19700101000000completo'
		;;
	'differenziale')
		# Find the last completo
		# Results are ordered alfabetically
		for dname in `ls -d ${destination_dir}/backup*completo/ 2>/dev/null`
		# The 2>/dev/null part of the command is the redirection STDERR to null
		# This is needed in order to prevent any error message from being diplayed: when
		# no directory is present, an error message is displayed (try to remove
		# the STDERR redirection and see what happens)
		do
			dname=`basename $dname`
		done
		
		if [ -z "$dname" ]
		then
			echo 'ERROR: unable to find any full backup' >&2
			echo "${destination_dir} does not seem to contain any full backup" >&2
			exit 10
		fi
		;;
	'incrementale')
		# Find the last incrementale
		# Results are ordered alfabetically
		for dname in `find ${destination_dir} -maxdepth 1 -type d -name backup*incrementale`
		# This is another way of listing all the directories contained in a specified path.
		# Actually this is the preferred way, as it provides many more options when compared
		# to ls
		do
			dname=`basename $dname`
		done
		
		if [ -z "$dname" ]
		then
			# Find the last completo
			# Results are ordered alfabetically
			for dname in `find ${destination_dir} -maxdepth 1 -type d -name backup*completo`
			do
				dname=`basename $dname`
			done
			
			if [ -z "$dname" ]
			then
				echo 'ERROR: unable to find any incremental or full backup' >&2
				echo "${destination_dir} does not seem to contain any incremental or full backup" >&2
				exit 11
			fi
		fi
		
		;;
	*)
		echo 'ERROR: unsupported backup type' >&2
		echo "${backup_type} is not supported" >&2
		exit 3
		;;
esac

#backup19780417231145incrementale
echo ${dname:6:14} 
