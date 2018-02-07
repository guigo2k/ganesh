FROM alpine:3.6

ADD app /app
WORKDIR /app

RUN apk --update add mongodb bash curl grep jq uwsgi-cgi && \
    adduser -h /app -s /bin/bash -D ganesh ganesh && \
    chown -R ganesh:ganesh /app

USER ganesh
EXPOSE 9090
CMD uwsgi --ini ganesh.ini
