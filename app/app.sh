#!/bin/bash

. martin.sh

get "/" root_handler
root_handler () {
    header "Content-Type" "text/html"
    cat "index.html"
}

get "/ps" ps_handler
ps_handler () {
    header "Content-Type" "text/plain"
    ps aux
}

get "/redirect" redirect_handler
redirect_handler () {
    status 302
    header "Location" "https://github.com/"
}

# run app 
martin_dispatch
