FROM alpine:3.2
MAINTAINER admin@tropicloud.net

ADD app /app
RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk --update add bash git curl uwsgi-cgi && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup ganesh && \ 
    adduser -D -G ganesh -s /bin/bash ganesh

USER ganesh
EXPOSE 8080
WORKDIR /app
CMD uwsgi \
--http-socket :8080 \
--http-socket-modifier1 9 \
--plugin-dir /usr/lib/uwsgi \
--plugin cgi \
--cgi app.sh
