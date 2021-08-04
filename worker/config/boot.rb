# frozen_string_literal: true

require 'bundler/setup'
require './lib/app'
Bundler.require(:default, App.env)

if App.env.development?
  require 'dotenv'
  filenames = [".env.#{App.env}"]
  filenames.unshift ".env.#{App.env}.local" unless ENV['DC'] # ENV['DC'] is "running in docker-compose" flag
  Dotenv.load(*filenames)
end

require_relative 'configus'

Dir['./config/initializers/**/*.rb'].each { |file| require file }
Dir['./config/patches/**/*.rb'].each { |file| require file }
Dir['./lib/*.rb'].each { |file| require file }
Dir['./lib/**/*.rb'].each { |file| require file }
