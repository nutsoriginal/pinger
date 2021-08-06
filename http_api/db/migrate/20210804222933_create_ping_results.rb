# frozen_string_literal: true

class CreatePingResults < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_results do |t|
      t.inet :ip, null: false
      t.decimal :latency, index: true
      t.datetime :created_at, null: false, index: true
    end
  end
end
