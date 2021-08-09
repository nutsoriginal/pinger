# frozen_string_literal: true

module Api
  module V1
    module Ping
      class TargetsController < ApplicationController
        # TODO: Refactor this very naive realization
        def create
          @ping_target = PingTarget.new(params[:ip])

          if @ping_target.valid?
            redis.lpush(configus.redis.queue.ready_to_ping.name, @ping_target.ip_address)

            render json: { status: :ok }
          else
            render json: { errors: @ping_target.errors.full_messages }
          end
        end

        # TODO: Refactor this very naive realization
        def remove
          @ping_target = PingTarget.new(params[:ip])

          if @ping_target.valid?
            redis.multi
            redis.lrem(configus.redis.queue.ready_to_ping.name, 0, @ping_target.ip_address)
            redis.lrem(configus.redis.queue.in_progress.name, 0, @ping_target.ip_address)
            redis.zrem(configus.redis.queue.timer_set.name, @ping_target.ip_address)
            redis.exec

            render json: { status: :ok }
          else
            render json: { errors: @ping_target.errors.full_messages }
          end
        end

        def redis
          @redis ||= Redis.new driver: :hiredis,
                               host: configus.redis.host,
                               port: configus.redis.port,
                               db: configus.redis.db
        end
      end
    end
  end
end
