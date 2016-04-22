#!/bin/bash

. ganesh.sh

get '/' && {
	header 'Content-Type' 'text/html'
	cat ./www/index.html
}

get '/say/:word/to/:name' && {
	echo "Say $word to $name"
}

get '/redirect' && {
	status 302
	header 'Location' 'https://github.com/'
}

get '/env' && { printenv; }

post '/post/*' && {
	echo $QUERY_STRING | sed 's/&/\n/g'
	echo $REQUEST_BODY | sed 's/&/\n/g'
}
