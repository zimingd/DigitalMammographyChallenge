'''
Created on Oct 24, 2016

@author: bhoff
'''

import github3
import synapseclient
import sys
import os

def main(argv=None):
    
    f = open('/lastthreadid.txt', 'r')
    lastidString = f.read()
    lastid = int(lastidString)
    f.close()
    
    print "last thread ID processed: ", lastid
    
    syn = synapseclient.Synapse()
    
    syn.login(os.environ['syn_user'], apiKey=os.environ['syn_apikey'])
    
    gh = github3.login(token=os.environ['github_token'])
    
    repository = gh.repository('Sage-Bionetworks', 'DigitalMammographyChallenge')
    
    projectId='syn4224222'
    offset=0
    limit=20
    
    totalNumberOfResults = sys.maxint
    while offset<totalNumberOfResults:
        threads=syn.restGET("/forum/79/threads?limit="+str(limit)+"&offset="+str(offset)+"&filter=EXCLUDE_DELETED&sort=PINNED_AND_LAST_ACTIVITY&ascending=true")
        totalNumberOfResults=int(threads.get('totalNumberOfResults'))
        for thread in threads.get('results'):
            threadid=int(thread.get('id'))
            if threadid<=lastid:
                continue
            if threadid==1122 or threadid==1123:
                # we made these while testing
                continue
            
            repository.create_issue(title=thread.get('title'), body='https://www.synapse.org/#!Synapse:'+projectId+'/discussion/threadId='+str(thread.get('id')), labels=['discussion forum'])
            
            print "Created issue for ", thread.get('id'), thread.get('title')
            lastid=threadid
            f = open('/lastthreadid.txt', 'w')
            f.write(str(lastid))
            f.close()
        
        #now get the next batch
        offset = offset + limit

    print "last thread ID processed: ", lastid
    
    return 0



if __name__ == "__main__":
    sys.exit(main())
    