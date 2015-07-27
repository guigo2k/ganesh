
```
                              _     
   __ _  __ _ _ __   ___  ___| |__  
  / _` |/ _` | '_ \ / _ \/ __| '_ \ 
 | (_| | (_| | | | |  __/\__ \ | | |
  \__, |\__,_|_| |_|\___||___/_| |_|
  |___/
                                
```                                                  

A sinatra-like web application micro-framework for bash with a CGI interface.

Example app:

```shell
# load framework
. ganesh.sh

# define handlers
GET "/" root_handler
root_handler () {
    header "Content-Type" "text/html"
    cat "index.html"
}

GET "/ps" ps_handler
ps_handler () {
    header "Content-Type" "text/plain"
    ps aux
}

GET "/redirect" redirect_handler
redirect_handler () {
    status 302
    header "Location" "https://github.com/"
}

# run app
ganesh_dance
    
```
