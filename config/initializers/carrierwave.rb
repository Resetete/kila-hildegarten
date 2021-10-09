CarrierWave.configure do |config|
  config.dropbox_access_token = Rails.application.credentials.dropbox[:access_token]
end
