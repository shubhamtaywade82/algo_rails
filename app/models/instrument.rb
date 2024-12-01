class Instrument < ApplicationRecord
  validates :exchange_id, :segment, presence: true

  scope :live_feed_instruments, -> { where(subscription_type: [ "Ticker", "Full" ]) }
end
