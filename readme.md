
docker build importissues .

docker run -e syn_user=${syn_user} -e syn_passwd=${syn_passwd} -e github_token=${github_token}-v <lastthreadit>:/lastthreadid.txt:rw importissues
