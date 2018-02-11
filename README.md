
```
                                __  
   ____ _____ _____  ___  _____/ /_
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/
/____/                              

```                                                  

## A web framework for Bash

Ganesh is a framework for writing web applications using Bash. It builds on [Docker](https://www.docker.com/) and the [uWSGI](https://github.com/unbit/uwsgi) app server for deploying self-contained, unprivileged bash applications.

### Quick start

```
docker run -it --rm --name mongo -p 27017:27017 mongo
docker run -it --rm --link mongo:mongo -p 9000:9000 tropicloud/ganesh:3.6
```

Now run the following in your terminal. For more examples see [app/README.md](app/README.md).

```
curl -i -X POST "http://localhost:9000/user" \
-H "Content-Type: application/json" \
-d '{"name": "John"}'
```

### Example app

```
#!/bin/bash

db() {
	mongo --quiet --host mongo --eval "$@"
}

. ganesh.sh
. user.sh

get  '/user'               && get_user
post '/user'               && post_user
get  '/user/:uuid/'        && get_user_id
put  '/user/:uuid/state'   && put_user_state
get  '/user/:uuid/state'   && get_user_state
put  '/user/:uuid/friends' && put_user_friends
get  '/user/:uuid/friends' && get_user_friends  
```

### Example handler
```
# ---------------------------------------------------------------------------------
# POST /user
# ---------------------------------------------------------------------------------
#
# curl -i -X POST "http://localhost:9000/user" \
# -H "Content-Type: application/json" \
# -d '{"name": "John"}'
#
# RESPONSE EXAMPLE:
# {
# "id": "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
# "name": "John"
# }

post_user() {
  name=$(echo "$DATA" | jq -r '.name')
  uuid=$(cat /proc/sys/kernel/random/uuid)

  read -r -d '' db_req <<EOF
db.user.insertOne({
  "id": "${uuid}",
  "name": "${name}"
})
EOF

  db_res=$(db "$db_req")
  obj_id=$(echo "$db_res" | grep -o 'ObjectId(.*)')

  if [[ -z $obj_id ]]; then
    echo "$db_res"
    exit 1
  fi

  read -r -d '' user <<EOF
db.user.find(
	${obj_id},
	{ _id: 0 }
).pretty()
EOF

  db "$user" | jq .
}
```

### Notes

Nginx natively supports upstream servers speaking the uwsgi protocol. See the [uWSGI docs](http://uwsgi-docs.readthedocs.org/en/latest/Nginx.html).
