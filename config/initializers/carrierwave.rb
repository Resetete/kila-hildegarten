CarrierWave.configure do |config|
  config.dropbox_access_token = Rails.application.credentials.dropbox[:access_token]
  #config.dropbox_app_key = Rails.application.credentials.dropbox[:app_key]
  #config.dropbox_app_secret = Rails.application.credentials.dropbox[:app_secret]
end
