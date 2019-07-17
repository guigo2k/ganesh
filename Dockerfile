FROM alpine:3.6

RUN apk --update add bash curl grep jq mongodb uwsgi-cgi && \
    adduser -h /app -s /bin/bash -D ganesh ganesh && \
    chown -R ganesh:ganesh /app

USER ganesh
EXPOSE 9090

ADD app /app
WORKDIR /app

CMD ["uwsgi", "--ini", "ganesh.ini"]
