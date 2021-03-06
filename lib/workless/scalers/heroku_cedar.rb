require 'heroku-api'

module Delayed
  module Workless
    module Scaler
      class HerokuCedar < Base
        extend Delayed::Workless::Scaler::HerokuClient

        def self.up
          puts "up call"
          puts "#{self.workers} < #{self.all_workers_needed}"
          if self.all_workers_needed > self.min_workers and self.workers < self.all_workers_needed
            puts "scaling up to #{self.all_workers_needed}"
            client.post_ps_scale(ENV['APP_NAME'], 'worker', self.all_workers_needed) 
          end
        end

        def self.down
          puts "down call" 
          puts "#{self.workers} > #{self.all_workers_needed}"
          if self.workers > self.all_workers_needed and self.boomerang_workers_needed == 0
            puts "scaling down to #{self.all_workers_needed}"
            client.post_ps_scale(ENV['APP_NAME'], 'worker', self.all_workers_needed) 
          end
        end

        def self.workers
          client.get_ps(ENV['APP_NAME']).body.count { |p| p["process"] =~ /worker\.\d?/ }
        end

        # Returns the number of workers needed based on the current number of pending jobs and the settings defined by:
        #
        # ENV['WORKLESS_WORKERS_RATIO']
        # ENV['WORKLESS_MAX_WORKERS']
        # ENV['WORKLESS_MIN_WORKERS']
        #
        def self.workers_needed
          w = [[(self.jobs.count.to_f / self.workers_ratio).ceil, self.max_workers].min, self.min_workers].max
          puts "workers needed = #{w}"
          w
        end

        def self.boomerang_workers_needed
          w = self.jobs("boomerang").count
          puts "boomerang workers needed = #{w}"
          w
        end

        def self.all_workers_needed
          self.workers_needed + self.boomerang_workers_needed
        end

        def self.workers_ratio
          if ENV['WORKLESS_WORKERS_RATIO'].present? && (ENV['WORKLESS_WORKERS_RATIO'].to_i != 0)
            ENV['WORKLESS_WORKERS_RATIO'].to_i
          else
            100
          end
        end

        def self.max_workers
          ENV['WORKLESS_MAX_WORKERS'].present? ? ENV['WORKLESS_MAX_WORKERS'].to_i : 1
        end

        def self.min_workers
          ENV['WORKLESS_MIN_WORKERS'].present? ? ENV['WORKLESS_MIN_WORKERS'].to_i : 0
        end
      end
    end
  end
end