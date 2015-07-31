#!/bin/bash

. ganesh.sh

get "/" && {
	header "Content-Type" "text/html"
	cat index.html
}

get "/say/*/to/*" && {
	header "Content-Type" "text/plain"
	echo Say ${url_param[0]} to ${url_param[1]}
}

get "/redirect" && {
	status 302
	header "Location" "https://github.com/"
}

post "/post/*" && {
	header "Content-Type" "text/plain"
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
	echo "Data: $POST_DATA"
}