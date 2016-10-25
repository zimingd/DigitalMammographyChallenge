
docker build -t brucehoff/importissues .

Copy last processed thread id to a file on the Docker Engine host

Copy config file to the Docker Engine host.  The contents should be
```
[synapse]
username: ...
apiKey: ...

[github]
token: ...
```

```
docker run -d  -v ...:/config.ini -v ...:/lastthreadid.txt:rw --name importissues brucehoff/importissues 
```