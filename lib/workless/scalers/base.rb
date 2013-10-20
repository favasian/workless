require 'delayed_job'

module Delayed
  module Workless
    module Scaler
  
      class Base
        def self.jobs(queue=nil)
          if Rails.version >= "3.0.0"
            Delayed::Job.where(:failed_at => nil, :queue=>queue)
          else
            Delayed::Job.all(:conditions => { :failed_at => nil, :queue=>queue })
          end
        end
      end

      module HerokuClient

        def client
          @client ||= ::Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
        end

      end

    end
  end
end
