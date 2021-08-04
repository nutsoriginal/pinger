# frozen_string_literal: true

require 'frankenstein/collected_metric'
require 'logger'

module Metrics
  module EmMetrics
    # rubocop:disable Metrics/MethodLength
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
        { { type: 'Fiber' } => stats[:Fiber], { type: 'Thread' } => stats[:Thread] }
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
