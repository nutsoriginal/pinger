#!/usr/bin/env sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

exec bundle exec rails s
