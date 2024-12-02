module Trading
  class StrategyFactory
    def self.build(payload)
      case payload["market"].upcase
      when "STOCK"
        StockStrategy.new(payload)
      when "INDEX"
        IndexStrategy.new(payload)
      else
        nil
      end
    end
  end
end
