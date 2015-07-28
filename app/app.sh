#!/bin/bash

. ganesh.sh

get "/" app_index
app_index() {
    header "Content-Type" "text/html"
    cat "index.html"
}

get "/ps" app_proc
app_proc() {
    header "Content-Type" "text/plain"
    ps aux
}

get "/redirect" app_redirect
app_redirect() {
    status 302
    header "Location" "https://github.com/"
}

# that's all
ganesh_dance
