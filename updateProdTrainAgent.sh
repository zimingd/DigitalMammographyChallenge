#!/bin/bash

# ./updateProdTrainAgent.sh 

DOCKER_MACHINE_NAME=$(docker-machine active)

docker stop ${DOCKER_MACHINE_NAME}-1-train
docker rm ${DOCKER_MACHINE_NAME}-1-train
docker stop ${DOCKER_MACHINE_NAME}-2-train
docker rm ${DOCKER_MACHINE_NAME}-2-train

docker pull brucehoff/challengedockeragent

./dmagentprod.sh train 1
./dmagentprod.sh train 2


