FROM alpine:3.2
MAINTAINER admin@tropicloud.net

RUN apk --update add bash uwsgi-cgi && \
    adduser -h /app -s /bin/bash -D ganesh ganesh

USER ganesh
ADD . /app
WORKDIR /app
CMD uwsgi \
--http-socket :8080 \
--http-socket-modifier1 9 \
--plugin-dir /usr/lib/uwsgi \
--plugin cgi \
--cgi app.sh
