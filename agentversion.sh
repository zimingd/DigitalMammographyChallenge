#!/bin/sh
# check the version of the challenge agent on each machine
agentvers() {
	eval $(docker-machine env $1)
	echo $1 $(docker images brucehoff/challengedockeragent:latest -q)	
}
agentvers bm04
agentvers bm07
agentvers bm08
agentvers bm09

