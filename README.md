
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

## A sinatra-like web app framework for Bash

Ganesh a is micro-framework for developing web apps using shell scripts. It builds on [Docker](https://www.docker.com/) and [uWSGI](https://github.com/unbit/uwsgi) application server for deploying self-contained (unprivileged) bash applications. 

### Quick start

```
docker run -it -p 8080:8080 tropicloud/ganesh
```


### Example app

```shell
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
    
```

### Note

By default, applications do not have access to the host system. You can --link your Ganesh app to other containers or --mount specific directories (volumes) from the host in order to accomplish specific server tasks.

For more information visit the [Docker Docs](https://docs.docker.com/).
