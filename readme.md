
```
python importissues.py config.ini lastThreadProcessed.txt syn4224222 79

```

Where:

config.ini is a file of the form:
```
[synapse]
username: ...
apiKey: ...

[github]
token: ...
```


lastThreadProcessed.txt is a writable file containing the ID of the last thread previously processed;

syn4224222 is the Synapse ID of the project to process

79 is the ID of the forum object in the aforementioned project

