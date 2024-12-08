module DataApiHelper
  def data_api_enabled?
    Rails.configuration.data_api_enabled
  end
end
