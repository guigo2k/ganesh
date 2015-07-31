#!/bin/bash

. ganesh.sh

GET "/" && {
	header "Content-Type" "text/html"
	cat index.html
}

GET "/say/*/to/*" && {
	header "Content-Type" "text/plain"
	echo Say ${uvi[0]} to ${uvi[1]}
}

GET "/redirect" && {
	status 302
	header "Location" "https://github.com/"
}

POST "/post/*" && {
	header "Content-Type" "text/plain"
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
	echo "Data: $POST_DATA"
}


