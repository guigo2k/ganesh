#!/bin/bash

. ganesh.sh

get '/' && {
	header "Content-Type" "text/html"
	cat index.html
}

get '/*' && {
	header "Content-Type" "text/plain"
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
}

get '/say/*/to/*' && {
	header "Content-Type" "text/plain"
	echo Say ${uri_var[0]} to ${uri_var[1]}
}

get "/redirect" && {
	status 302
	header "Location" "https://github.com/"
}
