
```
                                __  
   ____ _____ _____  ___  _____/ /_
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/
/____/                              

```                                                  

## A simple REST framework for Bash

Ganesh is a framework for writing web applications using Bash. It builds on [Docker](https://www.docker.com/) and the [uWSGI](https://github.com/unbit/uwsgi) app server for deploying self-contained, unprivileged bash applications.

### Quick start

```
docker-compose up
```

Now run the following in your terminal:

```bash
curl -i -X POST "http://localhost:9000/user" \
-H "Content-Type: application/json" \
-d '{"name": "John"}'
```

For more examples, check the [example app](https://github.com/tropicloud/ganesh/tree/master/app).

### Requirements
* [Docker](https://www.docker.com/)
* [docker-compose](https://github.com/docker/compose/)

### Example App

```bash
#!/bin/bash

. ganesh.sh
. user.sh

# http auth.
gnsh_auth "$token"

# db conn.
db() {
	mongo --quiet --host "mongo" --eval "$@"
}

put  '/user/:uuid/friends' && put_user_friends
get  '/user/:uuid/friends' && get_user_friends
put  '/user/:uuid/state'   && put_user_state
get  '/user/:uuid/state'   && get_user_state
get  '/user/:uuid'         && get_user_id
post '/user'               && post_user
get  '/user'               && get_user

```

### Example Handler
```bash
# GET /user/<userid>
# curl -X GET "http://localhost:9000/user/${uuid}/"

get_user_id() {
  read -r -d '' user <<EOF
db.user.find(
	{ "id": "${uuid}"},
	{ _id: 0 }
)
EOF

  db "$user" | jq .
}```

### Notes

Nginx natively supports upstream servers speaking the uwsgi protocol. See the [uWSGI docs](http://uwsgi-docs.readthedocs.org/en/latest/Nginx.html).
