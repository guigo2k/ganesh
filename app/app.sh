#!/bin/bash

. ganesh.sh
. user.sh

db() {
  mongo --quiet --host mongo --eval "$@"
}

put  '/user/:uuid/friends' && put_user_friends
get  '/user/:uuid/friends' && get_user_friends
put  '/user/:uuid/state'   && put_user_state
get  '/user/:uuid/state'   && get_user_state
get  '/user/:uuid'         && get_user_id
post '/user'               && post_user
get  '/user'               && get_user
get  '/'                   && gnsh_error 404
