# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require_relative 'lib/rack/health_check'

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use(Rack::Deflater)
use(Prometheus::Middleware::Collector)
use(Prometheus::Middleware::Exporter, path: '/metrics')

map '/health' do
  run Rack::HealthCheck.new
end

run Rails.application
Rails.application.load_server
