# frozen_string_literal: true

require 'frankenstein/process_metrics'

Frankenstein::ProcessMetrics.register(logger: Rails.logger)
