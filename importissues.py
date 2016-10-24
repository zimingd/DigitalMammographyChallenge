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
    
    syn = synapseclient.Synapse(os.environ['syn_user'], os.environ['syn_passwd'])
    
    syn.login()
    
    gh = github3.login(token=os.environ['github_token'])
    
    repository = gh.repository('Sage-Bionetworks', 'DigitalMammographyChallenge')
    
    projectId='syn4224222'
    offset=0
    limit=2
    # TODO get only the undeleted threads
    threads=syn.restGET("/forum/79/threads?limit="+str(limit)+"&offset="+str(offset)+"&filter=NO_FILTER&sort=PINNED_AND_LAST_ACTIVITY&ascending=true")
    
    # TODO track in a Synapse table which threads are already mirrored
    # TODO set a 'not before' thread ID
    for thread in threads.get('results'):
        print thread.get('id'), thread.get('title'), 'lastActivity: ', thread.get('lastActivity')
        id=int(thread.get('id'))
        if id<=lastid:
            continue
        issue = {
           'title': thread.get('title'),
           'body': 'https://www.synapse.org/#!Synapse:'+projectId+'/discussion/threadId='+str(thread.get('id'))
        }
        
        repository.import_issue(**issue)
        lastid=id
        f = open('/lastthreadid.txt', 'w')
        f.write(lastid)
        f.close()

    return 0

if __name__ == "__main__":
    sys.exit(main())
    