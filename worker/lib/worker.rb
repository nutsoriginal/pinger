# frozen_string_literal: true

# require 'active_record'

class Worker
  include Singleton

  def run
    # ::ActiveRecord::Base.logger = App.logger
    # ::ActiveRecord::Base.establish_connection :adapter      => "postgresql",
    #                                           :port         => 5432,
    #                                           :pool         => 2,
    #                                           :username     => "postgresadmin",
    #                                           :password     => "pass123",
    #                                           :host         => "localhost",
    #                                           :database     => "postgresadmin",
    #                                           :wait_timeout => 2

    EM.run do
      Trapper.run
      Meters.run
      Pinger.run
      Http::Server.run
      # EM.defer do
      #   ::ActiveRecord::Base.connection.execute "select pg_sleep(1)"
      #   ::ActiveRecord::Base.clear_active_connections!
      # end
    end
  end
end
