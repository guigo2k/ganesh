# load framework
. ganesh.sh

# define handlers
GET "/" ganesh_root
ganesh_root () {
    header "Content-Type" "text/html"
    cat "index.html"
}

GET "/ps" ganesh_ps
ganesh_ps () {
    header "Content-Type" "text/plain"
    ps aux
}

GET "/redirect" ganesh_redirect
ganesh_redirect () {
    status 302
    header "Location" "https://github.com/"
}

# run as CGI script
ganesh_dispatch
