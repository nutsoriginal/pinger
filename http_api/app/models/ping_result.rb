# frozen_string_literal: true

class PingResult < ApplicationRecord
  scope :statistics, lambda {
                       select(
                         'avg(latency) as avg, min(latency) as min, max(latency) as max, stddev(latency) as stddev, percentile_disc(0.5) within group (order by ping_results.latency) as median, 100.0 * (count(1) - count(latency)) / count(1) as percent_lost'
                       )
                     }
end
