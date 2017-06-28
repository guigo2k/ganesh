
```
                                __  
   ____ _____ _____  ___  _____/ /_ 
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/ 
/____/                              
                                  
```                                                  

## A web framework for Bash

Ganesh is a framework for writing web applications using Bash. It builds on [Docker](https://www.docker.com/) and the [uWSGI](https://github.com/unbit/uwsgi) app server for deploying self-contained, unprivileged bash applications.

### Quick start

```
docker run -p 9090:9090 -it tropicloud/ganesh
```

Now visit http://localhost:9090/ or run the following in your terminal:

```
curl -i -X POST "http://localhost:9090/post/path?app=my-app" \
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
	echo Say ${url_param[0]} to ${url_param[1]}
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
