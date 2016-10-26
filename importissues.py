'''
Created on Oct 24, 2016

@author: bhoff

Arguments:
config file with Synapse credentials and github token
writable file containing the ID of the last Synapse thread processed
Synapse project whose forum threads we are mirroring
forum ID of the forum in the aforementioned project

'''

import github3
import synapseclient

import sys
import ConfigParser

def log(s):
    print s

def main(argv=None):
    
    lost=[907, 908,  913, 916, 918,    923,    928,    934,    937,    939,
    942,
    951,
    953,
    963,
    966,
    970,
    974,
    976,
    977,
    978,
    980,
    981,
    990,
    997,
    1004,
    1017,
    1022,
    1024,
    1029,    1032,    1037,    1041,    1043,    1045,    1047,    1048,
    1051,    1054,    1067,    1068,    1069,    1081,    1084,    1101,    1114,    1125,    1127, 1128]

    config = ConfigParser.ConfigParser()
    config.read(argv[1])
    
    
    f = open(argv[2], 'r')
    lastidString = f.read()
    lastid = int(lastidString)
    f.close()
     
    log("last thread ID processed: "+str(lastid))
     
    syn = synapseclient.Synapse()
     
    syn.login(config.get('synapse', 'username'), apiKey=config.get('synapse', 'apiKey'))
     
    gh = github3.login(token=config.get('github', 'token'))
     
    repository = gh.repository('Sage-Bionetworks', 'DigitalMammographyChallenge')
    
    projectId=argv[3]
    forumId=argv[4]
    offset=0
    limit=20
     
    totalNumberOfResults = sys.maxint
    while offset<totalNumberOfResults:
        threads=syn.restGET("/forum/"+str(forumId)+"/threads?limit="+str(limit)+"&offset="+str(offset)+"&filter=EXCLUDE_DELETED&sort=PINNED_AND_LAST_ACTIVITY&ascending=true")
        totalNumberOfResults=int(threads.get('totalNumberOfResults'))
        for thread in threads.get('results'):
            threadid=int(thread.get('id'))
            if threadid<=lastid and not threadid in lost:
                continue
             
            # repository.create_issue(title=thread.get('title'), body='https://www.synapse.org/#!Synapse:'+projectId+'/discussion/threadId='+str(thread.get('id')), labels=['discussion forum'])
             
            log("Created issue for "+thread.get('id')+" "+thread.get('title'))
            lastid=threadid
            f = open(argv[2], 'w')
            f.write(str(lastid))
            f.close()
         
        #now get the next batch
        offset = offset + limit
 
    log("last thread ID processed: "+str(lastid))
    
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
    