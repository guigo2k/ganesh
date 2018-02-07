# POST /user
# REQUEST EXAMPLE:
# {
# "name": "John"
# }
# RESPONSE EXAMPLE:
# {
# "id": "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
# "name": "John"
# }

# curl -i -X POST "http://localhost:9090/user" \
# -H "Content-Type: application/json" \
# -d '{"name": "John"}'

post_user() {
  name=$(echo "$DATA" | jq -r '.name')
  uuid=$(cat /proc/sys/kernel/random/uuid)
  wreq="db.user.insertOne({ \"id\": \"${uuid}\", \"name\": \"${name}\" })"
  wres=$(db "$wreq")
  obid=$(echo "$wres" | grep -o 'ObjectId(.*)')

	if [[ -z $obid ]]; then
		echo "$wres"
		exit 1
	fi

  read -r -d '' user <<EOF
db.user.find(
	${obid},
	{ _id: 0 }
).pretty()
EOF

  db "$user" | jq .
}

# PUT /user/<userid>/state
# REQUEST EXAMPLE:
# {
# "gamesPlayed": 42,
# "score": 358
# }

# curl -X PUT "http://localhost:9090/user/f42967c0-00d8-4414-88d4-42fa60a03b75/state" \
# -H "Content-Type: application/json" \
# -d '{ "gamesPlayed": 54, "score": 364 }'

put_user_state() {
  games=$(echo "$DATA" | jq -r '.gamesPlayed')
  score=$(echo "$DATA" | jq -r '.score')

  read -r -d '' wreq <<EOF
db.user.update(
  { "id" : "${uuid}" },
  {
    \$set: { "gamesPlayed": $games, "score": $score },
    \$currentDate: { "lastModified": true }
  }
)
EOF

  db "$wreq" | awk -F "[()]" '{ print $2 }' | jq .
}
