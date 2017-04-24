# docker-nchan
NCHAN dockerized on ubuntu

#### run
```
docker run -d -p 4000:80 --name nchan iamaroot/nchan
```

#### server test
```
curl --request POST --data "test message" http://127.0.0.1:4000/pub
```

#### error.log
```
docker cp nchan:/nginx/logs/error.log error.log
```
