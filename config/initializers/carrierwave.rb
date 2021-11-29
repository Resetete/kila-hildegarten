CarrierWave.configure do |config|
  config.dropbox_access_token = Rails.application.credentials.dropbox_access_token
  #config.dropbox_access_token = ENV['DROPBOX_ACCESS_TOKEN']
end
