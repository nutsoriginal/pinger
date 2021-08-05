# frozen_string_literal: true

class Api::V1::Ping::StatisticsController < ApplicationController
  # TODO: Refactor this very naive realization
  def index
    @ping_target = PingTarget.new(params[:ip])

    if @ping_target.valid?
      statistics = ::PingResult.statistics.where(ip: @ping_target.ip_address)
      if params[:from].present? && params[:to].present?
        statistics = statistics.where(created_at: params[:from].to_datetime..params[:to].to_datetime)
      end

      render json: { statistics: statistics }
    else
      render json: { errors: @ping_target.errors.full_messages }
    end
  rescue ActiveRecord::StatementInvalid
    render json: { errors: ['No ping results found'] }, status: 404
  rescue StandardError => e
    puts e.inspect
    render json: { errors: [e.to_s] }, status: 500
  end
end
