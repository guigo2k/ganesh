
```
                                __  
   ____ _____ _____  ___  _____/ /_
  / __ `/ __ `/ __ \/ _ \/ ___/ __ \
 / /_/ / /_/ / / / /  __(__  ) / / /
 \__, /\__,_/_/ /_/\___/____/_/ /_/
/____/                              

```                                                  

### Quick start

```
docker run -p 9090:9090 -it tropicloud/ganesh
```

Visit http://localhost:9090/ or run the following:

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
	header 'Content-Type' 'text/html'
	cat ./www/index.html
}

get '/say/:word/to/:name' && {
	echo "Say $word to $name"
}

get '/redirect' && {
	status 302
	header 'Location' 'https://github.com/'
}

get '/env' && { printenv; }

post '/*' && {
	echo $QUERY_STRING | sed 's/&/\n/g'
	echo $REQUEST_BODY | sed 's/&/\n/g'
}
```
