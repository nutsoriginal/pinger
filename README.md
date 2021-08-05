# Pinger

### Description
The ping service

### Features

- Async pings
- Up to 1000RPS per worker with only ~30% CPU load

### Start
Demo in docker

    make docker-run
    bundle exec rake pinger:add_test_ips

Run only Redis and Postgres in docker

    make docker-services

Run worker on host machine

    make deps
    make run-worker

Run api on host machine

    make deps
    make run-api

### Dev
Checks (rubocop, fasterer && bundle-audit)

    make prechecks

### HTTP API

#### Rails

PING API

    curl -X GET http://localhost:3001/api/v1/ping/statistics?ip=8.8.8.8&from=2021-08-06&to=2077-01-01

    curl -i -X POST -H "Content-Type: application/json" http://localhost:3001/api/v1/ping/targets -d '{ "ip":"8.8.8.8" }'

    curl -i -X POST -H "Content-Type: application/json" http://localhost:3001/api/v1/ping/targets/remove -d '{ "ip":"8.8.8.8" }'

Scrapping

    curl -X GET http://localhost:3001/health

    curl -X GET http://localhost:3001/metrics

#### Worker

Scrapping

    curl -X GET http://localhost:3000/health

    curl -X GET http://localhost:3000/metrics

### TODO

- Write tests!!!
- Add swagger
- Use to ZRANGESTORE instead BRPOPLPUSH
- Pack as a gem
- Use TimescsleDB (or InfluxDB)
- Move to jobs generation
- Improve queuing
- Fix process kill issue
- Add CLI options
