#!/bin/bash
#
# This script starts the server-side agent for the Digital Mammography challenge
# Run from a shell which is also running Docker and Docker Machine, and 
# in which Docker Machine 'points' to the server on which to run the agent
#
#
#
# parameters are:
# role (train or score)
# agent index (1 or 2)
#
# The following are environment variables
# synapse username
# synapse password
# dockerhub username
# dockerhub password
#
ROLE=$1
AGENT_INDEX=$2

# The following is specific to the agent (differentiating the agents running on a host)
if [[ ${AGENT_INDEX} = 1 ]]; then
	GPUS=/dev/nvidia0,/dev/nvidia1
	AGENT_CPUS="0"
	CPUS="1-22"
elif [[ ${AGENT_INDEX} = 2 ]]; then
	GPUS=/dev/nvidia2,/dev/nvidia3
	AGENT_CPUS="24"
	CPUS="25-46"
else 
	echo "INVALID AGENT_INDEX " ${AGENT_INDEX}
	exit 1
fi

if [[ ${ROLE} = "train" ]]; then
	EVALUATION_IDS=7213944
elif [[ ${ROLE} = "score" ]]; then
	EVALUATION_IDS=7453778,7453793
else
	echo "INVALID ROLE " ${ROLE}
	exit 1
fi
# the following are the same for all queues
# this is a map from evaluation ID to role (train, score on sub-chall 1 or score on sub-chall 2)
# It is OK to have multiple queues that map to the same role
EVALUATION_ROLES=\{\"7213944\":\"TRAIN\",\"7453778\":\"SCORE_SC_1\",\"7453793\":\"SCORE_SC_2\"\}
TRAINING_DATA=/data/data/substitute-dcm #TODO update with production data
SC1_SCORING_DATA=/TBD # TODO
SC2_SCORING_DATA=/TBD # TODO
MODEL_STATE=/data/model${AGENT_INDEX}
TRAINING_SCRATCH=/data/scatch${AGENT_INDEX}
TRAINING_EXAM_METADATA_MOUNT=/data/data/training_exams_metadata_substitute.tsv:/metadata/exams_metadata.tsv # TODO
TRAINING_IMAGE_METADATA_MOUNT=/data/data/training_images_crosswalk_substitute.tsv:/metadata/images_crosswalk.tsv # TODO
SC1_SCORING_IMAGE_METADATA_MOUNT=/data/data/scoring_images_crosswalk_substitute.tsv:/metadata/images_crosswalk.tsv # TODO
SC2_SCORING_EXAM_METADATA_MOUNT=/data/data/scoring_exams_metadata_substitute.tsv:/metadata/exams_metadata.tsv # TODO
SC2_SCORING_IMAGE_METADATA_MOUNT=/data/data/scoring_images_crosswalk_substitute.tsv:/metadata/images_crosswalk.tsv # TODO

DOCKER_MACHINE_NAME=$(docker-machine active)
echo DOCKER_MACHINE_NAME=${DOCKER_MACHINE_NAME}
DOCKER_MACHINE_IP=$(docker-machine ip ${DOCKER_MACHINE_NAME})
echo DOCKER_MACHINE_IP=${DOCKER_MACHINE_IP}


if [[ ${DOCKER_MACHINE_IP} = "bm01-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.49
elif [[ ${DOCKER_MACHINE_IP} = "bm02-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.56
elif [[ ${DOCKER_MACHINE_IP} = "bm03-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.53
elif [[ ${DOCKER_MACHINE_IP} = "bm04-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.44
elif [[ ${DOCKER_MACHINE_IP} = "bm05-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.59
elif [[ ${DOCKER_MACHINE_IP} = "bm06-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.38
elif [[ ${DOCKER_MACHINE_IP} = "bm07-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.47
elif [[ ${DOCKER_MACHINE_IP} = "bm08-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.43
elif [[ ${DOCKER_MACHINE_IP} = "bm09-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.39
elif [[ ${DOCKER_MACHINE_IP} = "bm10-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.154.28.61
elif [[ ${DOCKER_MACHINE_IP} = "bm11-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.107
elif [[ ${DOCKER_MACHINE_IP} = "bm12-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.112
elif [[ ${DOCKER_MACHINE_IP} = "bm13-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.68
elif [[ ${DOCKER_MACHINE_IP} = "bm14-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.101
elif [[ ${DOCKER_MACHINE_IP} = "bm15-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.86
elif [[ ${DOCKER_MACHINE_IP} = "bm16-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.71
elif [[ ${DOCKER_MACHINE_IP} = "bm17-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.87
elif [[ ${DOCKER_MACHINE_IP} = "bm18-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.119
elif [[ ${DOCKER_MACHINE_IP} = "bm19-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.97
elif [[ ${DOCKER_MACHINE_IP} = "bm20-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.114
elif [[ ${DOCKER_MACHINE_IP} = "bm21-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.82
elif [[ ${DOCKER_MACHINE_IP} = "bm22-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.69
elif [[ ${DOCKER_MACHINE_IP} = "bm23-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.155.104.108
elif [[ ${DOCKER_MACHINE_IP} = "bm24-dreamchallenge.sl851865.sl.edst.ibm.com" ]]; then
	DOCKER_MACHINE_PRIVATE_IP=10.173.140.95
else
	echo "Unexpected DOCKER_MACHINE_IP" ${DOCKER_MACHINE_IP}
	exit 1
fi


docker run -d \
-e SYNAPSE_USERNAME=${SYNAPSE_USERNAME} \
-e SYNAPSE_PASSWORD=${SYNAPSE_PASSWORD} \
-e DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME} \
-e DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD} \
-e EVALUATION_IDS=${EVALUATION_IDS} \
-e GPUS=${GPUS} \
-e CPUS=${CPUS} \
-e NUM_GPU_DEVICES=2 \
-e NUM_CPU_CORES=22 \
-e MEMORY_GB=200 \
-e EVALUATION_ROLES=${EVALUATION_ROLES} \
-e RANDOM_SEED=12345 \
-v ${TRAINING_DATA}:/trainingData -e HOST_TRAINING_DATA=${TRAINING_DATA} \
-v ${SC1_SCORING_DATA}:/sc1ScoringData -e SC1_HOST_TESTING_DATA=${SC1_SCORING_DATA} \
-v ${SC2_SCORING_DATA}:/sc2ScoringData -e SC2_HOST_TESTING_DATA=${SC2_SCORING_DATA} \
-v ${MODEL_STATE}:/modelState -e HOST_MODEL_STATE=${MODEL_STATE} \
-v ${TRAINING_SCRATCH}:/scratch -e HOST_TRAINING_SCRATCH=${TRAINING_SCRATCH} \
-v /data/dataset0:/data/dataset0 \
-v /data/dataset1:/data/dataset1 \
-v /data/dataset2:/data/dataset2 \
-v /data/dataset3:/data/dataset3 \
-v /data/dataset4:/data/dataset4 \
-v /root/tempDir:/tempDir -e HOST_TEMP=/root/tempDir \
-v /etc/docker:/certs -e DOCKER_CERT_PATH=/certs \
-e DOCKER_ENGINE_URL=tcp://${DOCKER_MACHINE_IP}:2376 \
-e NVIDIA_PLUG_IN_HOST=${DOCKER_MACHINE_PRIVATE_IP}:3476 \
-e UPLOAD_PROJECT_ID=syn4224222 \
-e CONTAINER_OUTPUT_FOLDER_ENTITY_ID=syn7217450 \
-e SC1_PREDICTIONS_FOLDER_ID=syn7238736 \
-e SC2_PREDICTIONS_FOLDER_ID=syn7238747 \
-e AGENT_ENABLE_TABLE_ID=syn7211745 \
-e SERVER_SLOT_TABLE_ID=syn7214502 \
-e DATA_QUOTA_TABLE_ID=syn7568172 \
-e TRAINING_RO_VOLUMES=${TRAINING_EXAM_METADATA_MOUNT},${TRAINING_IMAGE_METADATA_MOUNT} \
-e SC1_RO_VOLUMES=${SC1_SCORING_IMAGE_METADATA_MOUNT} \
-e SC2_RO_VOLUMES=${SC2_SCORING_EXAM_METADATA_MOUNT},${SC2_SCORING_IMAGE_METADATA_MOUNT} \
-e HOST_ID=${DOCKER_MACHINE_NAME} \
-h ${DOCKER_MACHINE_NAME}-${AGENT_INDEX} \
--cpuset-cpus=${AGENT_CPUS} \
--name ${DOCKER_MACHINE_NAME}-${AGENT_INDEX}-${ROLE} brucehoff/challengedockeragent
