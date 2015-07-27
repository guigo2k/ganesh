FROM alpine:3.2
MAINTAINER admin@tropicloud.net

ADD app /app
RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk --update add bash git curl uwsgi-cgi && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080
WORKDIR /app
CMD uwsgi --ini /app/app.ini
