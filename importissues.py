'''
Created on Oct 24, 2016

@author: bhoff
'''

import github3
import synapseclient

import sys
import traceback
import ConfigParser

def log(s):
    print s

def main(argv=None):
    try:
        config = ConfigParser.ConfigParser()
        config.read(argv[0])
        
        
        f = open(argv[1], 'r')
        lastidString = f.read()
        lastid = int(lastidString)
        f.close()
         
        log("last thread ID processed: "+lastid)
         
        syn = synapseclient.Synapse()
         
        syn.login(config.get('synapse', 'username'), apiKey=config.get('synapse', 'apiKey'))
         
        gh = github3.login(token=config.get('github', 'token'))
         
        repository = gh.repository('Sage-Bionetworks', 'DigitalMammographyChallenge')
        
        projectId=argv[2]
        forumId=argv[3]
        offset=0
        limit=20
         
        totalNumberOfResults = sys.maxint
        while offset<totalNumberOfResults:
            threads=syn.restGET("/forum/"+str(forumId)+"/threads?limit="+str(limit)+"&offset="+str(offset)+"&filter=EXCLUDE_DELETED&sort=PINNED_AND_LAST_ACTIVITY&ascending=true")
            totalNumberOfResults=int(threads.get('totalNumberOfResults'))
            for thread in threads.get('results'):
                threadid=int(thread.get('id'))
                if threadid<=lastid:
                    continue
                if threadid==1122 or threadid==1123:
                    # we made these while testing
                    continue
                 
                repository.create_issue(title=thread.get('title'), body='https://www.synapse.org/#!Synapse:'+projectId+'/discussion/threadId='+str(thread.get('id')), labels=['discussion forum'])
                 
                log("Created issue for "+thread.get('id')+" "+thread.get('title'))
                lastid=threadid
                f = open('/lastthreadid.txt', 'w')
                f.write(str(lastid))
                f.close()
             
            #now get the next batch
            offset = offset + limit
     
        log("last thread ID processed: "+lastid)
        
        return 0
    
    except:
        exc_type, exc_value, exc_traceback = sys.exc_info()
        lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
        log('!! ' + line for line in lines)
        return 1

if __name__ == "__main__":
    sys.exit(main(sys.argv))
    