
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

## A sinatra-like CGI framework for Bash

Ganesh is a (micro) web application framework for shell scripts. It builds on [Docker](https://www.docker.com/) and [uWSGI](https://github.com/unbit/uwsgi) application server for deploying self-contained (unprivileged) bash applications. 

### Quick start

```
docker run -it -p 8080:8080 tropicloud/ganesh
```


### Example app

```shell
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
    
```

### Note

By default, applications do not have access to the host system. You can --link your Ganesh app to other containers or --mount specific directories (volumes) from the host in order to accomplish specific server tasks.

For more information visit the [Docker Docs](https://docs.docker.com/).
