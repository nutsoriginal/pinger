# Pinger

### Description
The ping service

### Features

- Async pings
- Up to 1000RPS per worker with only ~30% CPU load

### Start
Demo in docker

    make docker-run

Run Redis and Postgres in docker

    make docker-services

Run worker on host machine

    DEBUG=true LOG_LEVEL=debug bin/server.sh

### Dev
Checks (rubocop, fasterer && bundle-audit)

    make prechecks

### TODO

- Write tests!!!
- Use to ZRANGESTORE instead BRPOPLPUSH
- Pack as a gem
- Add CLI options
- Use TimescsleDB (or InfluxDB)
- Improve queuing
- Fix process kill issue
- Move to jobs generation
