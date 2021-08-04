# frozen_string_literal: true

module Trapper
  module_function

  def run
    log '=> Starting ping worker...'
    log "=> App environment: #{App.env}"

    # hit Control + C to stop
    Signal.trap('INT')  { EM.stop }
    Signal.trap('TERM') { EM.stop }

    EM.error_handler do |e|
      puts '----ERROR----', e.message, e.backtrace, '-------------'
    end

    EM.add_shutdown_hook { log '=> Exiting...' }
  end

  def log(message)
    App.logger.info message, 'trapper'
  end
end
