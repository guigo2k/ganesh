#!/bin/bash

. ganesh.sh

get '/' && {
	header "Content-Type" "text/html"
	cat index.html
}

get '/path/*' && {
	header "Content-Type" "text/plain"
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
}

get '/say/*/to/*' && {
	header "Content-Type" "text/plain"
	echo Say ${uva[0]} to ${uva[1]}
}

get "/redirect" && {
	status 302
	header "Location" "https://github.com/"
}
