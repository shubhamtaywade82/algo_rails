require "dhanhq"

Dhanhq.configure do |config|
  config.base_url = ENV["DHAN_URL"]
  config.client_id = ENV["DHAN_CLIENT_ID"]
  config.access_token = ENV["DHAN_ACCESS_TOKEN"]
end
