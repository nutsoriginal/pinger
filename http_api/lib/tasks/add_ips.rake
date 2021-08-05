# frozen_string_literal: true

namespace :pinger do
  desc 'Add test ips to ready_to_ping queue'
  task add_test_ips: :environment do
    redis = Redis.new driver: :hiredis,
                      host: configus.redis.host,
                      port: configus.redis.port,
                      db: configus.redis.db

    configus.ping.ips.each do |ip|
      puts ip
      redis.lpush(configus.redis.queue.ready_to_ping.name, ip)
    end
    puts '', 'Finished'
  end
end
