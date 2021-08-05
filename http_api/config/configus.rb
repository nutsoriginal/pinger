# frozen_string_literal: true

Configus.build Rails.env do
  env :default do
    redis do
      host Nenv.redis_host
      port Nenv.redis_port.to_i
      db Nenv.redis_db.to_i

      queue do
        ready_to_ping do
          name 'queue:ping:ready_to_ping'
        end
        in_progress do
          name 'queue:ping:in_progress'
        end
        timer_set do
          name 'queue:ping:timer_set'
        end
      end

      pool do
        size 10
        connection_timeout 2
      end
    end

    postgres do
      host Nenv.postgres_host
      port Nenv.postgres_port
      database Nenv.postgres_db
      user Nenv.postgres_user
      password Nenv.postgres_password

      pool do
        size 10
        connection_timeout 2
      end
    end
  end

  env :production, parent: :default

  env :development, parent: :default do
    ping do
      ips %w[
        8.8.8.8
        1.1.1.1
        173.194.222.138
        5.255.255.80
        74.6.143.26
        81.19.82.98
        217.69.139.202
        85.118.181.3
        77.88.55.66
        17.253.144.10
        31.13.72.36
        87.240.190.78
        3.220.76.115
        54.208.215.118
        87.240.137.158
        185.89.12.132
        91.215.37.237
        142.251.1.91
        178.248.233.148
        220.181.38.148
        104.244.42.129
        91.198.174.194
        205.251.242.103
        151.101.193.140
        217.20.155.13
        204.79.197.212
        128.75.237.34
        52.94.237.74
        31.31.205.163
        87.250.250.242
        91.236.51.153
        80.68.253.13
        104.197.180.14
        137.221.106.104
        106.10.248.150
        162.255.119.113
        91.198.174.192
        151.101.1.227
        178.237.20.14
        23.34.191.224
        142.250.150.103
        121.37.49.12
        31.13.72.52
        193.164.146.157
        193.164.146.253
        195.208.1.119
        104.17.109.12
        194.58.112.173
        103.136.221.168
        107.154.116.23
        185.137.235.88
        178.248.237.68
        94.124.200.0
        178.248.233.151
        95.163.95.29
        81.19.72.56
        178.248.232.209
        ]
    end
  end

  env :test, parent: :default
end
