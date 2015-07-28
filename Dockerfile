FROM alpine:3.2
MAINTAINER admin@tropicloud.net

ADD app /app
RUN apk --update add bash nano curl uwsgi-cgi && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/lib/apt/lists/* && \
    adduser -D -s /bin/bash ganesh ganesh

USER ganesh
EXPOSE 8080
WORKDIR /app
CMD uwsgi \
--http-socket :8080 \
--http-socket-modifier1 9 \
--plugin-dir /usr/lib/uwsgi \
--plugin cgi \
--cgi app.sh
