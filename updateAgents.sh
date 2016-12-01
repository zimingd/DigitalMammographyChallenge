#!/bin/bash

#TODO: check $# for correct # of args
usage(){
	echo "Usage:"
	echo -e "\t$0 role scriptToRun machineNames"
	echo "Parameters: "
	echo -e "\trole: either 'train' or 'score'"
	echo -e "\tscriptToRun: name of script to run for setting up an individual machine"
	echo -e "\tmachineNames: space separated machine names e.g. bm01 bm02 bm03"
	exit 1
}

if [[(($# < 3))]]; then
	usage 
fi

ROLE=$1
if [ ${ROLE} != "train" ] && [ ${ROLE} != "score" ]; then
	echo "INVALID ROLE: $ROLE"
	usage
fi

SCRIPT_TO_RUN=$2
#check script file exists
if [ ! -f $SCRIPT_TO_RUN ]; then
    echo "File: $SCRIPT_TO_RUN not found!"
    exit 1
fi



MACHINE_NAMES=${@:3}
#get list of current docker-machine names
VALID_NAMES=$(docker-machine ls -q)
#regex will be in fromat : ^(machineName1|machineName2|...|machineNameN)$
VALID_NAMES_REGEX="^($( echo "$VALID_NAMES" | paste -sd '|' - ))$"
#validate the passed parameters
for MACHINE_NAME in $MACHINE_NAMES; do
	if ! [[ $MACHINE_NAME =~ $VALID_NAMES_REGEX ]]; then
		echo "$MACHINE_NAME is not a valid docker-machine name. Please use names listed in 'docker-machine ls'"
		usage
		exit 1
	fi
done

checkForErrorExitCode(){
	local EXITCODE=$1
	local ERRROMESSAGE=$2
	if [ $EXITCODE -ne 0 ]; then
		echo $ERRROMESSAGE
	fi
}

#function to update each machine
updateMachine(){
	local MACHINE_NAME=$1	
	echo "Updating machine: $MACHINE_NAME"
	
	# set docker-machine to point to the machine
	local DOCKEREVAL=$(docker-machine env $MACHINE_NAME)
	#check exit code here because eval always returns 0 even if the inside fails
	checkForErrorExitCode $? "failed to set docker-machine to $MACHINE_NAME"
	eval $DOCKEREVAL


	#TODO: 01 or 1?
	#docker stop and remove container
	local CONTAINER_ONE_NAME=$MACHINE_NAME-$ROLE-1
	local CONTAINER_TWO_NAME=$MACHINE_NAME-$ROLE-2

	docker stop $CONTAINER_ONE_NAME
	checkForErrorExitCode $? "failed to stop container $CONTAINER_ONE_NAME"

	docker rm $CONTAINER_ONE_NAME
	checkForErrorExitCode $? "failed to remove container $CONTAINER_ONE_NAME"

	docker stop $CONTAINER_TWO_NAME
	checkForErrorExitCode $? "failed to stop container $CONTAINER_TWO_NAME"
	
	docker rm $CONTAINER_TWO_NAME
	checkForErrorExitCode $? "failed to remove container $CONTAINER_TWO_NAME"

	#pull latest image
	docker pull brucehoff/challengedockeragent
	checkForErrorExitCode $? "failed to pull latest image"

	#TODO: remove untagged images
	#docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

	#Run script to start the ageng
	./dmagent-prod $ROLE 1
	checkForErrorExitCode $? "failed to run script: '!!'"
	./dmagent-prod $ROLE 2
	checkForErrorExitCode $? "failed to run script: '!!'"

	echo "Sucessfully updated: $MACHINE_NAME"
}

# for MACHINE_NAME in $MACHINE_NAMES; do
# 	updateMachine $MACHINE_NAME
# done

echo "Reverting to local docker host."
#revert to using local docker
eval $(docker-machine env -u)