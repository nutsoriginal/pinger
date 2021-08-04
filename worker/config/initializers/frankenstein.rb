# frozen_string_literal: true

require 'frankenstein/process_metrics'
require './lib/metrics/em_metrics'

Frankenstein::ProcessMetrics.register(logger: App.logger)
Metrics::EmMetrics.register(logger: App.logger)
