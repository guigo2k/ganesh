#!/usr/bin/env bash

# load framework
. ganesh.sh

# define handlers
get "/" my_index
my_index () {
    header "Content-Type" "text/html"
    cat "index.html"
}

get "/ps" my_procs
my_procs () {
    header "Content-Type" "text/plain"
    ps aux
}

get "/redirect" my_redirect
my_redirect() {
    status 302
    header "Location" "https://github.com/"
}

# run app 
ganesh_dance
