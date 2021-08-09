# frozen_string_literal: true

module Http
  class Api < Sinatra::Base
    register Sinatra::Async

    use Rack::CommonLogger, App.logger

    configure do
      set :environment, App.env
      set :threaded, false
    end

    before do
      content_type :json
    end

    not_found do
      status 404
      body({ status: 'NOT FOUND' }.to_json)
    end

    aget '/health' do
      body({ status: 'OK' }.to_json)
    end
  end
end
