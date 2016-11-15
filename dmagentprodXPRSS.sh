#!/bin/bash
#
#
# This is the set up for the 'express lane' queues
#
#
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
# synapse username
# synapse password
# dockerhub username
# dockerhub password
#
ROLE=$1
AGENT_INDEX=$2
SYNAPSE_USERNAME=$3
SYNAPSE_PASSWORD=$4
DOCKERHUB_USERNAME=$5
DOCKERHUB_PASSWORD=$6

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
	EVALUATION_IDS=7500018
elif [[ ${ROLE} = "score" ]]; then
	EVALUATION_IDS=7500022,7500024
else
	echo "INVALID ROLE " ${ROLE}
	exit 1
fi
# the following are the same for all queues
# this is a map from evaluation ID to role (train, score on sub-chall 1 or score on sub-chall 2)
# It is OK to have multiple queues that map to the same role
EVALUATION_ROLES=\{\"7500018\":\"TRAIN\",\"7500022\":\"SCORE_SC_1\",\"7500024\":\"SCORE_SC_2\"\}
TRAINING_DATA=/data/data/images/training
SC1_SCORING_DATA=/data/data/images/SC1_leaderboard
SC2_SCORING_DATA=/data/data/images/SC2_leaderboard
MODEL_STATE=/data/model${AGENT_INDEX}
TRAINING_SCRATCH=/data/scatch${AGENT_INDEX}
TRAINING_EXAM_METADATA_MOUNT=/data/data/metadata/challenge/training_exams_metadata.tsv:/metadata/exams_metadata.tsv
TRAINING_IMAGE_METADATA_MOUNT=/data/data/metadata/challenge/training_images_crosswalk.tsv:/metadata/images_crosswalk.tsv
SC1_SCORING_IMAGE_METADATA_MOUNT=/data/data/metadata/challenge/SC1_leaderboard_images_crosswalk.tsv:/metadata/images_crosswalk.tsv
SC2_SCORING_EXAM_METADATA_MOUNT=/data/data/metadata/challenge/SC2_leaderboard_exams_metadata.tsv:/metadata/exams_metadata.tsv
SC2_SCORING_IMAGE_METADATA_MOUNT=/data/data/metadata/challenge/SC2_leaderboard_images_crosswalk.tsv:/metadata/images_crosswalk.tsv

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
-v /data/dataset5:/data/dataset5 \
-v /data/dataset6:/data/dataset6 \
-v /data/dataset7:/data/dataset7 \
-v /data/dataset8:/data/dataset8 \
-v /data/dataset9:/data/dataset9 \
-v /data/dataset10:/data/dataset10 \
-v /data/dataset11:/data/dataset11 \
-v /data/dataset12:/data/dataset12 \
-v /data/dataset13:/data/dataset13 \
-v /data/dataset14:/data/dataset14 \
-v /data/dataset15:/data/dataset15 \
-v /data/dataset16:/data/dataset16 \
-v /data/dataset17:/data/dataset17 \
-v /data/dataset18:/data/dataset18 \
-v /data/dataset19:/data/dataset19 \
-v /data/dataset20:/data/dataset20 \
-v /data/dataset21:/data/dataset21 \
-v /data/dataset22:/data/dataset22 \
-v /data/dataset23:/data/dataset23 \
-v /data/dataset24:/data/dataset24 \
-v /data/dataset25:/data/dataset25 \
-v /data/dataset26:/data/dataset26 \
-v /data/dataset27:/data/dataset27 \
-v /data/dataset28:/data/dataset28 \
-v /data/dataset29:/data/dataset29 \
-v /data/dataset30:/data/dataset30 \
-v /data/dataset31:/data/dataset31 \
-v /data/dataset32:/data/dataset32 \
-v /data/dataset33:/data/dataset33 \
-v /data/dataset34:/data/dataset34 \
-v /data/dataset35:/data/dataset35 \
-v /data/dataset36:/data/dataset36 \
-v /data/dataset37:/data/dataset37 \
-v /data/dataset38:/data/dataset38 \
-v /data/dataset39:/data/dataset39 \
-v /data/dataset40:/data/dataset40 \
-v /data/dataset41:/data/dataset41 \
-v /data/dataset42:/data/dataset42 \
-v /data/dataset43:/data/dataset43 \
-v /data/dataset44:/data/dataset44 \
-v /data/dataset45:/data/dataset45 \
-v /data/dataset46:/data/dataset46 \
-v /data/dataset47:/data/dataset47 \
-v /data/dataset48:/data/dataset48 \
-v /data/dataset49:/data/dataset49 \
-v /data/dataset50:/data/dataset50 \
-v /data/dataset51:/data/dataset51 \
-v /data/dataset52:/data/dataset52 \
-v /data/dataset53:/data/dataset53 \
-v /data/dataset54:/data/dataset54 \
-v /data/dataset55:/data/dataset55 \
-v /data/dataset56:/data/dataset56 \
-v /data/dataset57:/data/dataset57 \
-v /data/dataset58:/data/dataset58 \
-v /data/dataset59:/data/dataset59 \
-v /data/dataset60:/data/dataset60 \
-v /data/dataset61:/data/dataset61 \
-v /data/dataset62:/data/dataset62 \
-v /data/dataset63:/data/dataset63 \
-v /data/dataset64:/data/dataset64 \
-v /data/dataset65:/data/dataset65 \
-v /data/dataset66:/data/dataset66 \
-v /data/dataset67:/data/dataset67 \
-v /data/dataset68:/data/dataset68 \
-v /data/dataset69:/data/dataset69 \
-v /data/dataset70:/data/dataset70 \
-v /data/dataset71:/data/dataset71 \
-v /data/dataset72:/data/dataset72 \
-v /data/dataset73:/data/dataset73 \
-v /data/dataset74:/data/dataset74 \
-v /data/dataset75:/data/dataset75 \
-v /data/dataset76:/data/dataset76 \
-v /data/dataset77:/data/dataset77 \
-v /data/dataset78:/data/dataset78 \
-v /data/dataset79:/data/dataset79 \
-v /data/dataset80:/data/dataset80 \
-v /data/dataset81:/data/dataset81 \
-v /data/dataset82:/data/dataset82 \
-v /data/dataset83:/data/dataset83 \
-v /data/dataset84:/data/dataset84 \
-v /data/dataset85:/data/dataset85 \
-v /data/dataset86:/data/dataset86 \
-v /data/dataset87:/data/dataset87 \
-v /data/dataset88:/data/dataset88 \
-v /data/dataset89:/data/dataset89 \
-v /data/dataset90:/data/dataset90 \
-v /data/dataset91:/data/dataset91 \
-v /data/dataset92:/data/dataset92 \
-v /data/dataset93:/data/dataset93 \
-v /data/dataset94:/data/dataset94 \
-v /data/dataset95:/data/dataset95 \
-v /data/dataset96:/data/dataset96 \
-v /data/dataset97:/data/dataset97 \
-v /data/dataset98:/data/dataset98 \
-v /data/dataset99:/data/dataset99 \
-v /data/dataset100:/data/dataset100 \
-v /data/dataset101:/data/dataset101 \
-v /data/dataset102:/data/dataset102 \
-v /data/dataset103:/data/dataset103 \
-v /data/dataset104:/data/dataset104 \
-v /data/dataset105:/data/dataset105 \
-v /data/dataset106:/data/dataset106 \
-v /data/dataset107:/data/dataset107 \
-v /data/dataset108:/data/dataset108 \
-v /data/dataset109:/data/dataset109 \
-v /data/dataset110:/data/dataset110 \
-v /data/dataset111:/data/dataset111 \
-v /data/dataset112:/data/dataset112 \
-v /data/dataset113:/data/dataset113 \
-v /data/dataset114:/data/dataset114 \
-v /data/dataset115:/data/dataset115 \
-v /data/dataset116:/data/dataset116 \
-v /data/dataset117:/data/dataset117 \
-v /data/dataset118:/data/dataset118 \
-v /data/dataset119:/data/dataset119 \
-v /data/dataset120:/data/dataset120 \
-v /data/dataset121:/data/dataset121 \
-v /data/dataset122:/data/dataset122 \
-v /data/dataset123:/data/dataset123 \
-v /data/dataset124:/data/dataset124 \
-v /data/dataset125:/data/dataset125 \
-v /data/dataset126:/data/dataset126 \
-v /data/dataset127:/data/dataset127 \
-v /data/dataset128:/data/dataset128 \
-v /data/dataset129:/data/dataset129 \
-v /data/dataset130:/data/dataset130 \
-v /data/dataset131:/data/dataset131 \
-v /data/dataset132:/data/dataset132 \
-v /data/dataset133:/data/dataset133 \
-v /data/dataset134:/data/dataset134 \
-v /data/dataset135:/data/dataset135 \
-v /data/dataset136:/data/dataset136 \
-v /data/dataset137:/data/dataset137 \
-v /data/dataset138:/data/dataset138 \
-v /data/dataset139:/data/dataset139 \
-v /data/dataset140:/data/dataset140 \
-v /data/dataset141:/data/dataset141 \
-v /data/dataset142:/data/dataset142 \
-v /data/dataset143:/data/dataset143 \
-v /data/dataset144:/data/dataset144 \
-v /data/dataset145:/data/dataset145 \
-v /data/dataset146:/data/dataset146 \
-v /data/dataset147:/data/dataset147 \
-v /data/dataset148:/data/dataset148 \
-v /data/dataset149:/data/dataset149 \
-v /data/dataset150:/data/dataset150 \
-v /data/dataset151:/data/dataset151 \
-v /data/dataset152:/data/dataset152 \
-v /data/dataset153:/data/dataset153 \
-v /data/dataset154:/data/dataset154 \
-v /data/dataset155:/data/dataset155 \
-v /data/dataset156:/data/dataset156 \
-v /data/dataset157:/data/dataset157 \
-v /data/dataset158:/data/dataset158 \
-v /data/dataset159:/data/dataset159 \
-v /data/dataset160:/data/dataset160 \
-v /data/dataset161:/data/dataset161 \
-v /data/dataset162:/data/dataset162 \
-v /data/dataset163:/data/dataset163 \
-v /data/dataset164:/data/dataset164 \
-v /data/dataset165:/data/dataset165 \
-v /data/dataset166:/data/dataset166 \
-v /data/dataset167:/data/dataset167 \
-v /data/dataset168:/data/dataset168 \
-v /data/dataset169:/data/dataset169 \
-v /data/dataset170:/data/dataset170 \
-v /data/dataset171:/data/dataset171 \
-v /data/dataset172:/data/dataset172 \
-v /data/dataset173:/data/dataset173 \
-v /data/dataset174:/data/dataset174 \
-v /data/dataset175:/data/dataset175 \
-v /data/dataset176:/data/dataset176 \
-v /data/dataset177:/data/dataset177 \
-v /data/dataset178:/data/dataset178 \
-v /data/dataset179:/data/dataset179 \
-v /data/dataset180:/data/dataset180 \
-v /data/dataset181:/data/dataset181 \
-v /data/dataset182:/data/dataset182 \
-v /data/dataset183:/data/dataset183 \
-v /data/dataset184:/data/dataset184 \
-v /data/dataset185:/data/dataset185 \
-v /data/dataset186:/data/dataset186 \
-v /data/dataset187:/data/dataset187 \
-v /data/dataset188:/data/dataset188 \
-v /data/dataset189:/data/dataset189 \
-v /data/dataset190:/data/dataset190 \
-v /data/dataset191:/data/dataset191 \
-v /data/dataset192:/data/dataset192 \
-v /data/dataset193:/data/dataset193 \
-v /data/dataset194:/data/dataset194 \
-v /data/dataset195:/data/dataset195 \
-v /data/dataset196:/data/dataset196 \
-v /data/dataset197:/data/dataset197 \
-v /data/dataset198:/data/dataset198 \
-v /data/dataset199:/data/dataset199 \
-v /data/dataset200:/data/dataset200 \
-v /data/dataset201:/data/dataset201 \
-v /data/dataset202:/data/dataset202 \
-v /data/dataset203:/data/dataset203 \
-v /data/dataset204:/data/dataset204 \
-v /data/dataset205:/data/dataset205 \
-v /data/dataset206:/data/dataset206 \
-v /data/dataset207:/data/dataset207 \
-v /data/dataset208:/data/dataset208 \
-v /data/dataset209:/data/dataset209 \
-v /data/dataset210:/data/dataset210 \
-v /data/dataset211:/data/dataset211 \
-v /data/dataset212:/data/dataset212 \
-v /data/dataset213:/data/dataset213 \
-v /data/dataset214:/data/dataset214 \
-v /data/dataset215:/data/dataset215 \
-v /data/dataset216:/data/dataset216 \
-v /data/dataset217:/data/dataset217 \
-v /data/dataset218:/data/dataset218 \
-v /data/dataset219:/data/dataset219 \
-v /data/dataset220:/data/dataset220 \
-v /data/dataset221:/data/dataset221 \
-v /data/dataset222:/data/dataset222 \
-v /data/dataset223:/data/dataset223 \
-v /data/dataset224:/data/dataset224 \
-v /data/dataset225:/data/dataset225 \
-v /data/dataset226:/data/dataset226 \
-v /data/dataset227:/data/dataset227 \
-v /data/dataset228:/data/dataset228 \
-v /data/dataset229:/data/dataset229 \
-v /data/dataset230:/data/dataset230 \
-v /data/dataset231:/data/dataset231 \
-v /data/dataset232:/data/dataset232 \
-v /data/dataset233:/data/dataset233 \
-v /data/dataset234:/data/dataset234 \
-v /data/dataset235:/data/dataset235 \
-v /data/dataset236:/data/dataset236 \
-v /data/dataset237:/data/dataset237 \
-v /data/dataset238:/data/dataset238 \
-v /data/dataset239:/data/dataset239 \
-v /data/dataset240:/data/dataset240 \
-v /data/dataset241:/data/dataset241 \
-v /data/dataset242:/data/dataset242 \
-v /data/dataset243:/data/dataset243 \
-v /data/dataset244:/data/dataset244 \
-v /data/dataset245:/data/dataset245 \
-v /data/dataset246:/data/dataset246 \
-v /data/dataset247:/data/dataset247 \
-v /data/dataset248:/data/dataset248 \
-v /data/dataset249:/data/dataset249 \
-v /data/dataset250:/data/dataset250 \
-v /data/dataset251:/data/dataset251 \
-v /data/dataset252:/data/dataset252 \
-v /data/dataset253:/data/dataset253 \
-v /data/dataset254:/data/dataset254 \
-v /data/dataset255:/data/dataset255 \
-v /data/dataset256:/data/dataset256 \
-v /data/dataset257:/data/dataset257 \
-v /data/dataset258:/data/dataset258 \
-v /data/dataset259:/data/dataset259 \
-v /data/dataset260:/data/dataset260 \
-v /data/dataset261:/data/dataset261 \
-v /data/dataset262:/data/dataset262 \
-v /data/dataset263:/data/dataset263 \
-v /data/dataset264:/data/dataset264 \
-v /data/dataset265:/data/dataset265 \
-v /data/dataset266:/data/dataset266 \
-v /data/dataset267:/data/dataset267 \
-v /data/dataset268:/data/dataset268 \
-v /data/dataset269:/data/dataset269 \
-v /data/dataset270:/data/dataset270 \
-v /data/dataset271:/data/dataset271 \
-v /data/dataset272:/data/dataset272 \
-v /data/dataset273:/data/dataset273 \
-v /data/dataset274:/data/dataset274 \
-v /data/dataset275:/data/dataset275 \
-v /data/dataset276:/data/dataset276 \
-v /data/dataset277:/data/dataset277 \
-v /data/dataset278:/data/dataset278 \
-v /data/dataset279:/data/dataset279 \
-v /data/dataset280:/data/dataset280 \
-v /data/dataset281:/data/dataset281 \
-v /data/dataset282:/data/dataset282 \
-v /data/dataset283:/data/dataset283 \
-v /data/dataset284:/data/dataset284 \
-v /data/dataset285:/data/dataset285 \
-v /data/dataset286:/data/dataset286 \
-v /data/dataset287:/data/dataset287 \
-v /data/dataset288:/data/dataset288 \
-v /data/dataset289:/data/dataset289 \
-v /data/dataset290:/data/dataset290 \
-v /data/dataset291:/data/dataset291 \
-v /data/dataset292:/data/dataset292 \
-v /data/dataset293:/data/dataset293 \
-v /data/dataset294:/data/dataset294 \
-v /data/dataset295:/data/dataset295 \
-v /data/dataset296:/data/dataset296 \
-v /data/dataset297:/data/dataset297 \
-v /data/dataset298:/data/dataset298 \
-v /data/dataset299:/data/dataset299 \
-v /data/dataset300:/data/dataset300 \
-v /data/dataset301:/data/dataset301 \
-v /data/dataset302:/data/dataset302 \
-v /data/dataset303:/data/dataset303 \
-v /data/dataset304:/data/dataset304 \
-v /data/dataset305:/data/dataset305 \
-v /data/dataset306:/data/dataset306 \
-v /data/dataset307:/data/dataset307 \
-v /data/dataset308:/data/dataset308 \
-v /data/dataset309:/data/dataset309 \
-v /data/dataset310:/data/dataset310 \
-v /data/dataset311:/data/dataset311 \
-v /data/dataset312:/data/dataset312 \
-v /data/dataset313:/data/dataset313 \
-v /data/dataset314:/data/dataset314 \
-v /data/dataset315:/data/dataset315 \
-v /data/dataset316:/data/dataset316 \
-v /data/dataset317:/data/dataset317 \
-v /data/dataset318:/data/dataset318 \
-v /data/dataset319:/data/dataset319 \
-v /data/dataset320:/data/dataset320 \
-v /data/dataset321:/data/dataset321 \
-v /data/dataset322:/data/dataset322 \
-v /data/dataset323:/data/dataset323 \
-v /data/dataset324:/data/dataset324 \
-v /data/dataset325:/data/dataset325 \
-v /data/dataset326:/data/dataset326 \
-v /data/dataset327:/data/dataset327 \
-v /data/dataset328:/data/dataset328 \
-v /data/dataset329:/data/dataset329 \
-v /data/dataset330:/data/dataset330 \
-v /data/dataset331:/data/dataset331 \
-v /data/dataset332:/data/dataset332 \
-v /data/dataset333:/data/dataset333 \
-v /data/dataset334:/data/dataset334 \
-v /data/dataset335:/data/dataset335 \
-v /data/dataset336:/data/dataset336 \
-v /data/dataset337:/data/dataset337 \
-v /data/dataset338:/data/dataset338 \
-v /data/dataset339:/data/dataset339 \
-v /data/dataset340:/data/dataset340 \
-v /data/dataset341:/data/dataset341 \
-v /data/dataset342:/data/dataset342 \
-v /data/dataset343:/data/dataset343 \
-v /data/dataset344:/data/dataset344 \
-v /data/dataset345:/data/dataset345 \
-v /data/dataset346:/data/dataset346 \
-v /data/dataset347:/data/dataset347 \
-v /data/dataset348:/data/dataset348 \
-v /data/dataset349:/data/dataset349 \
-v /data/dataset350:/data/dataset350 \
-v /data/dataset351:/data/dataset351 \
-v /data/dataset352:/data/dataset352 \
-v /data/dataset353:/data/dataset353 \
-v /data/dataset354:/data/dataset354 \
-v /data/dataset355:/data/dataset355 \
-v /data/dataset356:/data/dataset356 \
-v /data/dataset357:/data/dataset357 \
-v /data/dataset358:/data/dataset358 \
-v /data/dataset359:/data/dataset359 \
-v /data/dataset360:/data/dataset360 \
-v /data/dataset361:/data/dataset361 \
-v /data/dataset362:/data/dataset362 \
-v /data/dataset363:/data/dataset363 \
-v /data/dataset364:/data/dataset364 \
-v /data/dataset365:/data/dataset365 \
-v /data/dataset366:/data/dataset366 \
-v /data/dataset367:/data/dataset367 \
-v /data/dataset368:/data/dataset368 \
-v /data/dataset369:/data/dataset369 \
-v /data/dataset370:/data/dataset370 \
-v /data/dataset371:/data/dataset371 \
-v /data/dataset372:/data/dataset372 \
-v /data/dataset373:/data/dataset373 \
-v /data/dataset374:/data/dataset374 \
-v /data/dataset375:/data/dataset375 \
-v /data/dataset376:/data/dataset376 \
-v /data/dataset377:/data/dataset377 \
-v /data/dataset378:/data/dataset378 \
-v /data/dataset379:/data/dataset379 \
-v /data/dataset380:/data/dataset380 \
-v /data/dataset381:/data/dataset381 \
-v /data/dataset382:/data/dataset382 \
-v /data/dataset383:/data/dataset383 \
-v /data/dataset384:/data/dataset384 \
-v /data/dataset385:/data/dataset385 \
-v /data/dataset386:/data/dataset386 \
-v /data/dataset387:/data/dataset387 \
-v /data/dataset388:/data/dataset388 \
-v /data/dataset389:/data/dataset389 \
-v /data/dataset390:/data/dataset390 \
-v /data/dataset391:/data/dataset391 \
-v /data/dataset392:/data/dataset392 \
-v /data/dataset393:/data/dataset393 \
-v /data/dataset394:/data/dataset394 \
-v /data/dataset395:/data/dataset395 \
-v /data/dataset396:/data/dataset396 \
-v /data/dataset397:/data/dataset397 \
-v /data/dataset398:/data/dataset398 \
-v /data/dataset399:/data/dataset399 \
-v /root/tempDir:/tempDir -e HOST_TEMP=/root/tempDir \
-v /etc/docker:/certs -e DOCKER_CERT_PATH=/certs \
-e DOCKER_ENGINE_URL=tcp://${DOCKER_MACHINE_IP}:2376 \
-e NVIDIA_PLUG_IN_HOST=${DOCKER_MACHINE_PRIVATE_IP}:3476 \
-e UPLOAD_PROJECT_ID=syn4224222 \
-e CONTAINER_OUTPUT_FOLDER_ENTITY_ID=syn7217450 \
-e SC1_PREDICTIONS_FOLDER_ID=syn7238736 \
-e SC2_PREDICTIONS_FOLDER_ID=syn7238747 \
-e AGENT_ENABLE_TABLE_ID=syn7211745 \
-e SERVER_SLOT_TABLE_ID=syn7413559 \
-e TRAINING_RO_VOLUMES=${TRAINING_EXAM_METADATA_MOUNT},${TRAINING_IMAGE_METADATA_MOUNT} \
-e SC1_RO_VOLUMES=${SC1_SCORING_IMAGE_METADATA_MOUNT} \
-e SC2_RO_VOLUMES=${SC2_SCORING_EXAM_METADATA_MOUNT},${SC2_SCORING_IMAGE_METADATA_MOUNT} \
-e HOST_ID=${DOCKER_MACHINE_NAME} \
-h ${DOCKER_MACHINE_NAME}-${AGENT_INDEX} \
--cpuset-cpus=${AGENT_CPUS} \
--name ${DOCKER_MACHINE_NAME}-${AGENT_INDEX}-${ROLE} brucehoff/challengedockeragent
