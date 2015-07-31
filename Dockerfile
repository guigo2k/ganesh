FROM alpine:3.2
MAINTAINER admin@tropicloud.net

RUN adduser -h /app -s /bin/bash -D ganesh ganesh
ADD . /app
RUN apk --update add bash curl uwsgi-cgi && \
    chown -R ganesh:ganesh /app

USER ganesh
HOME /app

EXPOSE 8080
CMD uwsgi \
--http-socket :8080 \
--http-socket-modifier1 9 \
--plugin-dir /usr/lib/uwsgi \
--plugin cgi \
--cgi app.sh
