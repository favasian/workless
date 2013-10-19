module Delayed
  module Workless
    module Scaler

      class Null < Base
      
        def self.up(queue=nil)
        end

        def self.down
        end

      end
      
    end
  end
end
