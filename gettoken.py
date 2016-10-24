'''
Created on Oct 24, 2016

@author: bhoff
'''
from github3 import authorize
from getpass import getpass
import sys

def main(argv=None):
    
    user = ''
    
    while not user:
        user = raw_input("github username: ")
        
    password = ''
    
    while not password:
        password = getpass('Password for {0}: '.format(user))
    
    note = 'github3.py example app'
    note_url = 'http://example.com'
    scopes = ['user', 'repo']
    
    auth = authorize(user, password, scopes, note, note_url)
    
    print 'auth.token: ', auth.token
    print 'auth.id: ', auth.id

if __name__ == "__main__":
    sys.exit(main())
    