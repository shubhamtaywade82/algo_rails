class AlertLogger
  def self.log(payload)
    Rails.logger.info "Logging alert: #{payload.inspect}"
    # Save to database or log file as needed
  end
end
