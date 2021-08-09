# frozen_string_literal: true

require 'logger'
require 'em-logger'

class SignedLogger < EM::Logger
  def initialize(*args)
    logger = Logger.new(*args)
    logger.level = ENV['LOG_LEVEL'] || :error

    super(logger)
  end

  %i[debug info warn error fatal unknown].each do |method_name|
    define_method method_name do |progname, sender = nil, request_id = nil, &block|
      request_id ||= SecureRandom.uuid

      message = [
        "[#{request_id}]",
        "[#{sender}]",
        progname
      ].compact.join(' ')

      super(message, &block)
    end
  end
end
