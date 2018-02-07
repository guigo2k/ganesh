#!/bin/bash

db() {
	mongo --quiet --host mongo --eval "$@"
}

. ganesh.sh
. user.sh

post '/user'             && post_user
put  '/user/:uuid/state' && put_user_state
