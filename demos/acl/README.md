# Demo of ACL plugin

This demo deploys a simple httpbin service and enable [JWT authentication plugin](https://docs.konghq.com/hub/kong-inc/jwt/) on route `/jwt` . A consumer will also be created with two JWT credentials. One for HS256 and the other for RS256. This demo will then generate JWT tokens with both signing algorithm and demonstrate how to consume the route. Check the code to find out how these tokens are calculated.

## Install

```bash
make install
```

## Test this step

```bash
make test
./test.sh
Forwarding from 127.0.0.1:8081 -> 8000
Forwarding from [::1]:8081 -> 8000

No Token:
We are going to make below call WITHOUT JWT Token:

curl -i http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1'

*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
> GET /jwt HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
> X-Kong-Debug: 1
>
Handling connection for 8081
< HTTP/1.1 401 Unauthorized
< Date: Wed, 10 Feb 2021 01:22:00 GMT
< Content-Type: application/json; charset=utf-8
< Connection: keep-alive
< Content-Length: 26
< X-Kong-Response-Latency: 0
< Server: kong/2.2.1.0-enterprise-edition
<
{ [26 bytes data]
* Connection #0 to host localhost left intact
* Closing connection 0
{
  "message": "Unauthorized"
}

Next we are going to try JWT token signed with RS256 algorithm.

RS256 signature algorithm:
curl -i http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1' \
    -H "Authorization:Bearer eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpYXQiOjE2MTI5MjAxMjAsImV4cCI6MTYxMjkyMDY2MCwiaXNzIjoiand0LXJzMjU2LXRlc3Qta2V5In0.GVyrHkNGloAnYeMQqi1i9XjfGsoM9-5XYSaJ51nQlOLWj2h7HQUzjHcf_ULkp0E6affIt1J5EgK2rB37vfr6g-gIptYZ04925exsIf7jvpPc0LYKZ5IK0mMj8ED886_mh8LKPdH_iI8Ki8emsZMzXJY0GoGbOW563GHjDD8cWnNjHfKi_a6cJZVWwXlu3_bsdzLKIQsPuX6KGO7vTz4U3pOybciI9I52Pz0wEYspNtliQ2xTTgf0mKP33Ed7iozFCw909qhATgSlVvYVwBxyVprYBiklogSLsIZxWPraxHTJyVQGHsSuZOgcrHEDp7gTNPEZN2Uf9EhB65c5Fi_tOA"

Press any key to continue or Ctrl+C to exit...

*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
Handling connection for 8081
> GET /jwt HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
> X-Kong-Debug: 1
> Authorization:Bearer eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpYXQiOjE2MTI5MjAxMjAsImV4cCI6MTYxMjkyMDY2MCwiaXNzIjoiand0LXJzMjU2LXRlc3Qta2V5In0.GVyrHkNGloAnYeMQqi1i9XjfGsoM9-5XYSaJ51nQlOLWj2h7HQUzjHcf_ULkp0E6affIt1J5EgK2rB37vfr6g-gIptYZ04925exsIf7jvpPc0LYKZ5IK0mMj8ED886_mh8LKPdH_iI8Ki8emsZMzXJY0GoGbOW563GHjDD8cWnNjHfKi_a6cJZVWwXlu3_bsdzLKIQsPuX6KGO7vTz4U3pOybciI9I52Pz0wEYspNtliQ2xTTgf0mKP33Ed7iozFCw909qhATgSlVvYVwBxyVprYBiklogSLsIZxWPraxHTJyVQGHsSuZOgcrHEDp7gTNPEZN2Uf9EhB65c5Fi_tOA
>
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 1090
< Connection: keep-alive
< Server: gunicorn/19.9.0
< Date: Wed, 10 Feb 2021 01:22:03 GMT
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Credentials: true
< X-Kong-Upstream-Latency: 3
< X-Kong-Proxy-Latency: 0
< Via: kong/2.2.1.0-enterprise-edition
<
{ [1090 bytes data]
* Connection #0 to host localhost left intact
* Closing connection 0
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpYXQiOjE2MTI5MjAxMjAsImV4cCI6MTYxMjkyMDY2MCwiaXNzIjoiand0LXJzMjU2LXRlc3Qta2V5In0.GVyrHkNGloAnYeMQqi1i9XjfGsoM9-5XYSaJ51nQlOLWj2h7HQUzjHcf_ULkp0E6affIt1J5EgK2rB37vfr6g-gIptYZ04925exsIf7jvpPc0LYKZ5IK0mMj8ED886_mh8LKPdH_iI8Ki8emsZMzXJY0GoGbOW563GHjDD8cWnNjHfKi_a6cJZVWwXlu3_bsdzLKIQsPuX6KGO7vTz4U3pOybciI9I52Pz0wEYspNtliQ2xTTgf0mKP33Ed7iozFCw909qhATgSlVvYVwBxyVprYBiklogSLsIZxWPraxHTJyVQGHsSuZOgcrHEDp7gTNPEZN2Uf9EhB65c5Fi_tOA",
    "Connection": "keep-alive",
    "Host": "localhost:8081",
    "User-Agent": "curl/7.64.1",
    "X-Consumer-Id": "722d30bc-06d6-5bd1-988d-1ccea6bf397b",
    "X-Consumer-Username": "jwt-user",
    "X-Credential-Identifier": "jwt-rs256-test-key",
    "X-Forwarded-Host": "localhost",
    "X-Forwarded-Path": "/jwt",
    "X-Forwarded-Prefix": "/jwt",
    "X-Kong-Debug": "1"
  },
  "json": null,
  "method": "GET",
  "origin": "127.0.0.1",
  "url": "http://localhost/anything"
}

Lastly we are going to try JWT token signed with HS256 algorithm.

HS256 signature algorithm:
curl -i http://localhost:8081/jwt \
    -H 'X-Kong-Debug: 1' \
    -H "Authorization:Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNjEyOTIwMTIzIiwiZXhwIjoxNjEyOTIwNjYzLCJpc3MiOiJqd3QtdGVzdGVyLWtleSJ9.MIBKqxbKLItedkdcWKT5bmfguqQu1N9jtqhiy-oXKNg"

Press any key to continue or Ctrl+C to exit...

*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
> GET /jwt HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
> X-Kong-Debug: 1
> Authorization:Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNjEyOTIwMTIzIiwiZXhwIjoxNjEyOTIwNjYzLCJpc3MiOiJqd3QtdGVzdGVyLWtleSJ9.MIBKqxbKLItedkdcWKT5bmfguqQu1N9jtqhiy-oXKNg
>
Handling connection for 8081
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 782
< Connection: keep-alive
< Server: gunicorn/19.9.0
< Date: Wed, 10 Feb 2021 01:22:06 GMT
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Credentials: true
< X-Kong-Upstream-Latency: 3
< X-Kong-Proxy-Latency: 0
< Via: kong/2.2.1.0-enterprise-edition
<
{ [782 bytes data]
* Connection #0 to host localhost left intact
* Closing connection 0
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNjEyOTIwMTIzIiwiZXhwIjoxNjEyOTIwNjYzLCJpc3MiOiJqd3QtdGVzdGVyLWtleSJ9.MIBKqxbKLItedkdcWKT5bmfguqQu1N9jtqhiy-oXKNg",
    "Connection": "keep-alive",
    "Host": "localhost:8081",
    "User-Agent": "curl/7.64.1",
    "X-Consumer-Id": "722d30bc-06d6-5bd1-988d-1ccea6bf397b",
    "X-Consumer-Username": "jwt-user",
    "X-Credential-Identifier": "jwt-tester-key",
    "X-Forwarded-Host": "localhost",
    "X-Forwarded-Path": "/jwt",
    "X-Forwarded-Prefix": "/jwt",
    "X-Kong-Debug": "1"
  },
  "json": null,
  "method": "GET",
  "origin": "127.0.0.1",
  "url": "http://localhost/anything"
}
```

## What am I seeing?

In the above requests you can see the first request was blocked. The next two requests went through to the service as the user ` jwt-user`.  The first JWT token was generated with the RS256 credential and the last JWT token was generated with HS256 credential.
