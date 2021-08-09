# frozen_string_literal: true

require 'frankenstein/collected_metric'
require 'logger'

module Metrics
  module EmMetrics
    def self.register(registry = Prometheus::Client.registry, logger: Logger.new('/dev/null'))
      Frankenstein::CollectedMetric.new(
        :event_loop_latency,
        docstring: 'EM event loop latency im ms',
        registry: registry,
        logger: logger
      ) do
        { {} => Meters.latency }
      end

      Frankenstein::CollectedMetric.new(
        :concurrency_level,
        docstring: 'EM concurrency level',
        registry: registry,
        logger: logger,
        labels: [:type]
      ) do
        stats = Meters.concurrency_level
        {
          { type: 'Fibers' } => stats[:Fibers],
          { type: 'Threads' } => stats[:Threads],
          { type: 'Connections' } => stats[:Connections],
          { type: 'Timers' } => stats[:Timers]
        }
      end

      Frankenstein::CollectedMetric.new(
        :performance,
        docstring: 'worker performance',
        registry: registry,
        logger: logger,
        labels: [:type]
      ) do
        {
          { type: 'pops_per_sec' } => Pinger.pops_per_sec,
          { type: 'pings_per_sec' } => Pinger.pings_per_sec,
          { type: 'ready_to_ping_queue_len' } => Pinger.ready_to_ping_queue_len,
          { type: 'in_progress_queue_len' } => Pinger.in_progress_queue_len,
          { type: 'timer_set_size' } => Pinger.timer_set_size
        }
      end
    end
  end
end
