class Alert < ApplicationRecord
  validates :ticker, :close, :time, :action, :market, :exchange, presence: true
  validates :volume, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  enum :status, { pending: "pending", processed: "processed", failed: "failed" }
end
