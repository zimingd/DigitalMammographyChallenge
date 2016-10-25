
docker build -t brucehoff/importissues .

Copy last processed thread id to a file on the Docker Engine host which is to run the container

```
docker run -e -d syn_user=... \
-e syn_apikey=... \
-e github_token=... \
-v ...:/lastthreadid.txt:rw \
--name importissues \
brucehoff/importissues 
```