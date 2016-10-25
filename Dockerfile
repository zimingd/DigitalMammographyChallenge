FROM python:2.7
RUN pip install synapseclient
RUN pip install --pre github3.py
# CMD python /importissues.py
RUN apt-get update && apt-get install cron
COPY crontab /etc/cron.d/importissues-cron
CMD cron
COPY importissues.py /importissues.py
