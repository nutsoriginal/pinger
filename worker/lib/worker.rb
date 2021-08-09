# frozen_string_literal: true

# require 'active_record'

class Worker
  include Singleton

  def run
    EM.run do
      Trapper.run
      Meters.run
      Pinger.run
      Http::Server.run
    end
  end
end
