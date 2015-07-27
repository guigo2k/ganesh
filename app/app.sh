# load framework
. ganesh.sh

# define handlers
get "/" gnsh_root
gnsh_root () {
    header "Content-Type" "text/html"
    cat "index.html"
}

get "/ps" gnsh_ps
gnsh_ps () {
    header "Content-Type" "text/plain"
    ps aux
}

get "/redirect" gnsh_redirect
gnsh_redirect () {
    status 302
    header "Location" "https://github.com/"
}

# run app 
ganesh_dance
