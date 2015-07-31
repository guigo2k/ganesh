
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

## A Sinatra-like CGI framework for Bash

Ganesh is a framework for writing micro-services using shell scripts. It builds on [Docker](https://www.docker.com/) and the [uWSGI](https://github.com/unbit/uwsgi) app server for deploying self-contained, unprivileged bash applications. 

### Quick start

```
docker run -p 8080:8080 -it tropicloud/ganesh
```

Now visit http://localhost:8080/ or run the following in your terminal:

```
curl -i -X POST "http://localhost:8080/post/path?app=my-app" \
-H "Content-Type: application/json" \
-d '{"name": "my-name", "age": "my-age"}'
```

### Example app

```shell
#!/bin/bash

. ganesh.sh

get '/' && {
	header "Content-Type" "text/html"
	cat index.html
}

get '/say/*/to/*' && {
	header "Content-Type" "text/plain"
	echo Say ${uvi[0]} to ${uvi[1]}
}

get "/redirect" && {
	status 302
	header "Location" "https://github.com/"
}

post '/post/*' && {
	header "Content-Type" "text/plain"
	echo "Path: $PATH_INFO"
	echo "Query: $QUERY_STRING"
	echo "Data: $POST_DATA"
}
    
```

### Notes

Nginx natively supports upstream servers speaking the uwsgi protocol. See the [uWSGI docs](http://uwsgi-docs.readthedocs.org/en/latest/Nginx.html).

By default, applications do not have access to the host system. You can --link your app to other containers or mount specific directories from your host  using Docker volumes.

For more information visit the [Docker docs](https://docs.docker.com/).
