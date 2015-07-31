#!/bin/bash

. ganesh.sh

get '/' && {
    header "Content-Type" "text/html"
	cat index.html
}

get '/*' && {
    header "Content-Type" "text/plain"
	echo "PATH_INFO: $PATH_INFO"
	echo "QUERY_STRING: $QUERY_STRING"
}

get '/say/*/to/*' && {
    header "Content-Type" "text/plain"
	echo Say ${uri_var[0]} to ${uri_var[1]}
}

get "/redirect" && {
 	status 302
    header "Location" "https://github.com/"
}
