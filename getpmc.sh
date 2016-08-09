#!/bin/sh
#
check_hwpmc() {

# should fail if hwpmc is not availble

}

KERNDIR="/boot/kernel"

#
# main
#
check_hwpmc

if [ $# -lt 1 ]; then
	echo "No event-spec given. Assuming CPU_CLK_UNHALTED_CORE..."
	EVENT="CPU_CLK_UNHALTED_CORE"
else 
	EVENT=${1}
fi

if [ $# -lt 2 ]; then
	echo "No sleep time specified. Assuming 10 seconds..."
	SLEEP="10"
else
	SLEEP=${2}
fi

echo "Instrumenting for ${SLEEP} seconds..."
pmcstat -S ${EVENT} -O ${EVENT}.pmc sleep ${SLEEP}
echo "Extracting stack trace..."
pmcstat -R ${EVENT}.pmc -z100 -G ${EVENT}.stacks.txt
echo "Annotating..."
pmcannotate -k ${KERNDIR} ${EVENT}.pmc ${KERNDIR}/kernel > ${EVENT}.annotated.txt
echo "Extracting gprof(1) profile data..."
pmcstat -R ${EVENT}.pmc -g
gprof -K ${KERNDIR}/kernel ${EVENT}/kernel.gmon > ${EVENT}.gprof-kernel.txt

if [ -d ${EVENT} ]; then
	echo "Cleaning up..."
	rm -r ${EVENT}
fi	
