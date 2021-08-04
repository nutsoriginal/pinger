# frozen_string_literal: true

require 'pg/em'

class Pinger
  class << self
    attr_accessor :pop_counter, :ping_counter

    def run
      @pop_counter = 0
      @ping_counter = 0
      @results = []

      enable_dubug_logs if configus.debug
      prepare

      poll_redis_timers_set
      process_ping_queue
      periodically_persist_data
    end

    private

    def process_ping_queue
      EM.defer do
        loop do
          ip = sync_redis.brpoplpush(configus.redis.queue.ready_to_ping.name, configus.redis.queue.in_progress.name)
          self.pop_counter += 1 if configus.debug

          EM.next_tick do
            ping(ip) do |ip, latency|
              save_result(ip, latency)
              enqueue_delayed(ip)
              self.ping_counter += 1 if configus.debug
            end
          end
        end
      end
    end

    def poll_redis_timers_set
      EM.add_periodic_timer(configus.ping.quantize) do
        time_point = Time.now.to_f
        # TODO: use ZRANGESTORE when it will be available
        async_redis.with do |conn|
          conn.multi
          conn.zrangebyscore(configus.redis.queue.timer_set.name, 0, time_point)
          conn.zremrangebyscore(configus.redis.queue.timer_set.name, 0, time_point)
          df = conn.exec
          df.callback do |response|
            move_elapsed_to_work(response[0])
          end
        end
      end
    end

    def periodically_persist_data
      EM.add_periodic_timer(1) { write_results_to_db }
    end

    def ping(ip)
      start_time = Time.now
      request = icmp_manager.ping ip
      request.callback do
        end_time = Time.now
        latency = end_time - start_time
        yield ip, latency
      end
      request.errback do
        yield ip
      end
    end

    def enqueue_delayed(ip)
      EM.next_tick do
        async_redis.zadd(configus.redis.queue.timer_set.name, (Time.now.to_f + configus.ping.interval), ip)
      end
    end

    def move_elapsed_to_work(ips)
      async_redis.with do |conn|
        conn.multi
        ips.each do |ip|
          conn.lrem(configus.redis.queue.in_progress.name, 0, ip)
          conn.lpush(configus.redis.queue.ready_to_ping.name, ip)
        end
        conn.exec
      end if ips.any?
    end

    Result = Struct.new(:ip, :latency, :created_at) do
      def initialize(ip, latency, created_at = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z'))
        super(ip, latency, created_at)
      end

      def to_sql_string
        lat = latency || 'NULL'
        "('%s', %s, '%s')" % [ip, lat, created_at]
      end

      def to_log_string
        lat_string = latency ? "Latency #{latency}s" : 'FAILED'
        "PING: IP #{ip.ljust(15)} #{lat_string}"
      end
    end

    def save_result(ip, latency = nil)
      result = Result.new(ip, latency)
      @results << result
      log_result(result) if configus.debug
    end

    def write_results_to_db
      # TODO: use active_record with adapter
      query = "INSERT INTO PINGS (ip, latency, created_at) VALUES #{@results.map(&:to_sql_string).join(', ')};"
      df = async_pg.async_query(query)

      if configus.debug
        df.callback { |response| log_pg(response) }
        df.errback { |response| log_pg(response) }
      end

      @results = []
    end

    def log_pg(response)
      text =  if response.is_a?(PG::Result)
                response.cmd_status
              elsif response.is_a?(PG::Error)
                response.to_s
              end

      log text, 'pg'
    end

    def log_result(result)
      log result.to_log_string
    end

    def icmp_manager
      @icmp_manager ||= ICMP4EM::Manager.new(timeout: configus.ping.time_out, retries: configus.ping.retries_count)
    end

    def async_redis
      redis_url = "redis://#{configus.redis.host}:#{configus.redis.port}/#{configus.redis.db}"
      redis_client = -> { EM::Hiredis.connect redis_url }
      @async_redis ||=
        begin
          EM::Hiredis.logger = App.logger
          ConnectionPool.wrap(
            {
              pool: ConnectionPool.new(
                size: configus.redis.pool.size,
                timeout: configus.redis.pool.connection_timeout
              ) { redis_client.call }
            }
          )
        end
    end

    def sync_redis
      @sync_redis ||= Redis.new driver: :hiredis,
                                host: configus.redis.host,
                                port: configus.redis.port,
                                db: configus.redis.db
    end

    def async_pg
      postgres_client = -> do
        ::PG::EM::Client.new host: configus.postgres.host,
                             port: configus.postgres.port,
                             dbname: configus.postgres.database,
                             user: configus.postgres.user,
                             password: configus.postgres.password
      end

      @async_pg ||= ConnectionPool.wrap(
        {
          pool: ConnectionPool.new(
            size: configus.postgres.pool.size,
            timeout: configus.postgres.pool.connection_timeout
          ) { postgres_client.call }
        }
      )
    end

    def log(message, initiator = 'pinger')
      App.logger.debug message, initiator
    end

    def enable_dubug_logs
      EM.add_periodic_timer 1 do
        EM.defer do
          async_redis.llen(configus.redis.queue.ready_to_ping.name) do |len|
            log "METERS: Ready to ping queue size: #{len}"
          end
          async_redis.llen(configus.redis.queue.in_progress.name) do |len|
            log "METERS: In progress queue size: #{len}"
          end
          async_redis.zcard(configus.redis.queue.timer_set.name) do |size|
            log "METERS: Delayed set size: #{size}"
          end
          log "METERS: Queue pops count #{self.pop_counter}"
          log "METERS: Ping complete count #{self.ping_counter}"
          self.pop_counter = 0
          self.ping_counter = 0
        end
      end
    end

    def prepare
      async_redis.del(configus.redis.queue.ready_to_ping.name)
      async_redis.del(configus.redis.queue.in_progress.name)
      async_redis.del(configus.redis.queue.timer_set.name)
      configus.ping.ips.each { |ip| async_redis.lpush(configus.redis.queue.ready_to_ping.name, ip) }
      async_redis.llen(configus.redis.queue.ready_to_ping.name) { |v| p v }
    end
  end
end

