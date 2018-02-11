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

  read -r -d '' user <<EOF
var user = db.user.insertOne({
  "id": "${uuid}",
  "name": "${name}"
});
db.user.find(
  { _id: user.insertedId },
  { _id: 0 }
)
EOF

  db "$user" | jq .
}

# ---------------------------------------------------------------------------------
# PUT /user/<userid>/state
# ---------------------------------------------------------------------------------
#
# curl -X PUT "http://localhost:9000/user/${uuid}/state" \
# -H "Content-Type: application/json" \
# -d '{ "gamesPlayed": 54, "score": 364 }'
#
# REQUEST EXAMPLE:
# {
# "gamesPlayed": 42,
# "score": 358
# }

put_user_state() {
  games=$(echo "$DATA" | jq -r '.gamesPlayed')
  score=$(echo "$DATA" | jq -r '.score')

  read -r -d '' state <<EOF
var state = db.user.update(
  { "id": "${uuid}" },
  { \$set: { "gamesPlayed": ${games}, "score": ${score} }}
);
state.getRawResponse()
EOF

  db "$state" | jq .
}


# ---------------------------------------------------------------------------------
# PUT /user/<userid>/friends
# ---------------------------------------------------------------------------------
#
# curl -X PUT "http://localhost:9000/user/${uuid}/friends" \
# -H "Content-Type: application/json" \
# -d '{ "friends": [ "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1", "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08", "2d18862b-b9c3-40f5-803e-5e100a520249" ] }'
#
# REQUEST EXAMPLE:
# {
#   "friends": [
#     "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
#     "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08",
#     "2d18862b-b9c3-40f5-803e-5e100a520249"
#   ]
# }

put_user_friends() {
  friends=$(echo "$DATA" | jq -r '.friends')

  read -r -d '' friends <<EOF
var friends = db.user.update(
  { "id": "${uuid}" },
  { \$set: { "friends": ${friends} }}
);
friends.getRawResponse()
EOF

  db "$friends" | jq .
}


# ---------------------------------------------------------------------------------
# GET /user/<userid>/state
# ---------------------------------------------------------------------------------
#
# curl -X GET "http://localhost:9000/user/${uuid}/state"
#
# RESPONSE EXAMPLE:
# {
# "gamesPlayed": 42,
# "score": 358
# }

get_user_state() {

    read -r -d '' state <<EOF
db.user.find(
	{ "id": "${uuid}"},
	{ _id: 0, gamesPlayed: 1, score: 1 }
)
EOF

    db "$state" | jq .
}

# ---------------------------------------------------------------------------------
# GET /user/<userid>/friends
# ---------------------------------------------------------------------------------
#
# curl -X GET "http://localhost:9000/user/${uuid}/friends"
#
# RESPONSE EXAMPLE:
# {
#   "friends": [
#     {
#       "id": "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
#       "name": "John",
#       "highscore": 322
#     },
#     {
#       "id": "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08",
#       "name": "Bob",
#       "highscore": 21
#     },
#     {
#       "id": "2d18862b-b9c3-40f5-803e-5e100a520249",
#       "name": "Alice",
#       "highscore": 99332
#     }
#   ]
# }

get_user_friends() {

    read -r -d '' friends <<EOF
db.user.find(
	{ "id": "${uuid}"},
	{ _id: 0, friends: 1, }
)
EOF

    db "$friends" | jq .
}

# ---------------------------------------------------------------------------------
# GET /user/<userid>
# ---------------------------------------------------------------------------------
#
# curl -X GET "http://localhost:9000/user/${uuid}/"
#
# RESPONSE EXAMPLE:
# {
#   "id": "db5cf52f-805a-42c0-9533-a7083f81dac9",
#   "name": "John",
#   "gamesPlayed": 54,
#   "score": 364,
#   "friends": [
#     "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
#     "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08",
#     "2d18862b-b9c3-40f5-803e-5e100a520249"
#   ]
# }

get_user_id() {
  read -r -d '' user <<EOF
db.user.find(
	{ "id": "${uuid}"},
	{ _id: 0 }
)
EOF

  db "$user" | jq .
}

# ---------------------------------------------------------------------------------
# GET /user
# ---------------------------------------------------------------------------------
#
# curl -X GET "http://localhost:9000/user"
#
# RESPONSE EXAMPLE:
# {
#   "users": [
#     {
#       "id": "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1",
#       "name": "John"
#     },
#     {
#       "id": "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08",
#       "name": "Bob"
#     }
#   ]
# }

get_user() {

  read -r -d '' user <<EOF
var user = db.user.find({}, { _id: 0, id: 1, name: 1 }).toArray();
var resp = { "users": user };
printjson( resp )
EOF

  db "$user" | jq .
}
