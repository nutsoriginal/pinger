# frozen_string_literal: true

require 'active_support/string_inquirer'
require './lib/signed_logger'

module App
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['APP_ENV'] || 'development')
    end

    def logger
      @logger ||= ::SignedLogger.new(log_output)
    end

    def start
      Worker.instance.run
    end

    private

    def log_output
      $stdout.sync = true
      $stdout
    end
  end
end
