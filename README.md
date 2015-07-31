
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

## Sinatra-like CGI framework for Bash

Ganesh is a (micro) web application framework written in bash. It builds on [Docker](https://www.docker.com/) and [uWSGI](https://github.com/unbit/uwsgi) application server for deploying self-contained, unprivileged bash applications. 

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
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
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

By default, applications do not have access to the host system. You can --link your app to other containers or mount specific directories from the host using Docker volumes.

For more information visit the [Docker Docs](https://docs.docker.com/).
