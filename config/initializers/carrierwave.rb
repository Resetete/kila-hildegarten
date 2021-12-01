CarrierWave.configure do |config|
  config.dropbox_access_token = Rails.application.credentials.dropbox_access_token
end
