#!/bin/bash

# ./updateXPRSSTrainAgent.sh 

DOCKER_MACHINE_NAME=$(docker-machine active)

docker stop ${DOCKER_MACHINE_NAME}-1-train
docker rm ${DOCKER_MACHINE_NAME}-1-train
docker stop ${DOCKER_MACHINE_NAME}-2-train
docker rm ${DOCKER_MACHINE_NAME}-2-train

docker pull brucehoff/challengedockeragent

./dmagentprodXPRSS.sh train 1
./dmagentprodXPRSS.sh train 2



