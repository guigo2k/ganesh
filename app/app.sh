#!/usr/bin/env bash

. ganesh.sh
. user.sh

# http authorization
http_auth "$token"

# database connection
db() { mongo --quiet --host mongo --eval "$@"; }

# http routes
PUT  '/user/:uuid/friends' && put_user_friends
GET  '/user/:uuid/friends' && get_user_friends
PUT  '/user/:uuid/state'   && put_user_state
GET  '/user/:uuid/state'   && get_user_state
GET  '/user/:uuid'         && get_user_id
POST '/user'               && post_user
GET  '/user'               && get_user
