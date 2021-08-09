# frozen_string_literal: true

require 'resolv'

class PingTarget
  include ActiveModel::Validations

  attr_accessor :ip_address

  validates :ip_address, presence: true, format: { with: Resolv::IPv4::Regex }

  def initialize(ip_address)
    @ip_address = ip_address
  end
end
