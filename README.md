# docker-nchan
NCHAN dockerized on ubuntu

#### build
```
docker build -t nchan .
```

#### run
```
docker run -it -p 4000:80 --name nchan nchan
```

#### start
```
docker start nchan
```

#### server test
```
curl --request POST --data "test message" http://127.0.0.1:4000/pub
```

#### error.log
```
docker cp nchan:/nginx/logs/error.log error.log
```
