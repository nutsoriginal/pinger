# frozen_string_literal: true

module Rack
  class HealthCheck
    def call(_)
      [200, {}, []]
    end
  end
end
