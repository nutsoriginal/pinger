# frozen_string_literal: true
require 'active_support/core_ext/module'

class Meters
  class << self
    attr_reader :latency

    def run
      @last_em_ping = Time.now.to_f

      EM.add_periodic_timer(configus.metrics.update_period) do
        current_time = Time.now.to_f
        @latency = (current_time - @last_em_ping - configus.metrics.update_period) * 1000
        @last_em_ping = current_time
        if configus.debug
          log "METERS: Loop latency %.5f ms" % latency
          log "METERS: Connections count: #{connection_count}"
          log "METERS: Timers count: #{timer_count}"
        end
      end
    end

    def concurrency_level
      stats = { Fiber: 0, Thread: 0 }
      ObjectSpace.each_object(Fiber) { |obj| stats[:Fiber] += 1 if obj.alive? }
      ObjectSpace.each_object(Thread) { stats[:Thread] += 1 }

      stats
    end

    private

    delegate :connection_count, to: EM

    def timer_count
      EM.instance_variable_get(:@timers).count
    end

    def log(message)
      App.logger.debug message, 'meters'
    end
  end
end
