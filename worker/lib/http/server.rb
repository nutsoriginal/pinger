# frozen_string_literal: true

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

module Http
  class Server
    class << self
      def run
        log "=> Starting HTTP server with params #{configus.http_server.to_hash}}"

        EM.defer do
          server.start!
        end
      end

      private

      def server
        @server ||= Thin::Server.new(
          configus.http_server.host,
          configus.http_server.port,
          signals: false
        ) do
          use Rack::CommonLogger, App.logger
          use(Prometheus::Middleware::Collector)
          use(Prometheus::Middleware::Exporter, path: '/metrics')

          map '/' do
            run Http::Api.new
          end
        end

        @server.silent = true

        @server
      end

      def log(message)
        App.logger.info message, 'http_server'
      end
    end
  end
end
