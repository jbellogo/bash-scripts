


#!/bin/bash -x
# usage: produceOutputs suite-file program_to_run
# suite-file contains a list of stems, .args files exist and if not, a blank temporary file is passed.
# script produces .out files from the gven programa nd in accordance to the stems in the suite-file

usage() {
	echo "Error: Expects two arguments" >&2
	echo "Usage: ${0} suite_file program" >&2  # this doesnt go to stdout, but stderr
	exit 1
}

if [ $# -ne 2 ] || [ ! -r "${2}" ] || [ ! -r "${1}" ] ; then
	usage
fi


for test in $(cat ${1}) ; do

	if [ ! -r ${test}.args ] ; then
		
		if [ ! -r ${test}.in ] ; then    # no arguments, no standard input
			temp=$(mktemp)
			chmod a=rwx ${temp}
			"${2}" < ${temp} > ${test}.out     # if you put the ./ before, you mess up runnign it from different directories
			rm ${temp}
		else                                 # no arguments, standard input
			"${2}" < ${test}.in > ${test}.out
		fi

	else

		if [ ! -r ${test}.in ] ; then    # arguments, no standard input
			"${2}" $(cat ${test}.args) > ${test}.out
		else
			"${2}" $(cat ${test}.args) < ${test}.in > ${test}.out
		fi
	fi
done

