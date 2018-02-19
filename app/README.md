#### POST /user
```
token='bea376cb4ed3daad21e16d0bc25bd281'

curl -X POST "http://localhost:9000/user" \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
-d '{"name": "John"}'
```

#### PUT /user/:uuid/state
```
curl -X PUT "http://localhost:9000/user/${uuid}/state" \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
-d '{ "gamesPlayed": 54, "score": 364 }'
```

#### PUT /user/:uuid/friends
```
curl -X PUT "http://localhost:9000/user/${uuid}/friends" \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
-d '{ "friends": [ "18dd75e9-3d4a-48e2-bafc-3c8f95a8f0d1", "f9a9af78-6681-4d7d-8ae7-fc41e7a24d08", "2d18862b-b9c3-40f5-803e-5e100a520249" ] }'
```

#### GET /user/:uuid
```
curl -X GET "http://localhost:9000/user/${uuid}" \
-H "Authorization: Bearer $token"
```

#### GET /user/:uuid/state
```
curl -X GET "http://localhost:9000/user/${uuid}/state" \
-H "Authorization: Bearer $token"
```

#### GET /user/:uuid/friends
```
curl -X GET "http://localhost:9000/user/${uuid}/friends" \
-H "Authorization: Bearer $token"
```

#### GET /user
```
curl -X GET "http://localhost:9000/user" \
-H "Authorization: Bearer $token"
```
