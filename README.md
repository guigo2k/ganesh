
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

### A sinatra-like web app framework for Bash

Ganesh is micro-framework for developing server-side web applications using shell scripts. It builds on Docker for deploying applications to containers. By default, apps DO NOT have direct access to the host system. You can "link" your Ganesh app to other apps (containers) or "mount" specific directories from the host in order to accomplish specific server tasks.

Quick start:

```
docker run -it -p 8080:8080 tropicloud/ganesh
```

Example app:

```shell
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
    
```
