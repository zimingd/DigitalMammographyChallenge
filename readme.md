## To set up a server and run the challenge agent, e.g. on bm08:

### set up the server
./setupNewServer.sh bm08
### 'point' to the Docker Engine (daemon) on the new server
eval $(docker-machine env bm08)
### start up 'agent 1' (which governs GPU0,1)
./dmagentprodXPRSS.sh train 1
### start up 'agent 2' (which governs GPU2,3)
./dmagentprodXPRSS.sh train 2
