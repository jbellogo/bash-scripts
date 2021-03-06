
#!/bin/bash -x
# usage: ./runSuite suite-file program

usage() {
	echo "Error: two argumenets and an existing" >&2
	echo "usage: ${0} suite-file program" >&2
	exit 1
}

nonexistant() {
	echo "missing or unreadable file in test_suit" >&2 
	exit 1
}

if [ ${#} -ne 2 ] || [ ! -r "${2}" ] || [ ! -r "${1}" ] ; then
	usage
fi

for tests in $(cat ${1}) ; do

	#Check if at least one .out missing, program stops
	if [ ! -r ${tests}.out ] ; then
		nonexistant
	fi
	
	# make a temporal file to store .exp and compare to .out
	expected=$(mktemp) 
	chmod a=rwx ${expected}

	# check if .args file does not exist
	if [ ! -r ${tests}.args ] ; then

		if [ ! -r ${tests}.in ] ; then    # no arguments, no standard input
			$("${2}" > ${expected})
		else                                # no arguments, standard input
			$("${2}" < ${tests}.in > ${expected})
		fi

	else 		# arguments	
		if [ ! -r "${tests}".in ] ; then    # arguments, no standard input
			$("${2}" $(cat "${tests}".args) > ${expected})
		else                                 # argumetns, standard input
			$("${2}" $(cat "${tests}".args) < ${tests}.in > ${expected})
		fi

	fi

	#compare the files 
	diff ${tests}.out ${expected} >> /dev/null

	if [ ${?} -ne 0 ] ; then
		echo Test failed: "${tests}"
		echo Args:
		cat "${tests}".args
		echo Input:
		cat "${tests}".in
		echo Expected:	
		cat "${tests}".out
		echo Actual:
		cat "${expected}"
	fi
	
	rm "${expected}"
done

