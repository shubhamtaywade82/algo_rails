# app/services/orders/strategies/base_strategy.rb
module Orders
  module Strategies
    class BaseStrategy
      def initialize(alert)
        @alert = alert
      end

      def execute
        raise NotImplementedError, "#{self.class} must implement #execute"
      end

      private

      attr_reader :alert
    end
  end
end
