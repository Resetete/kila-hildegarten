# config/initializers/secure_headers.rb

# CSP and X-Frame-Options are managed in config/application.rb
# to avoid the secure_headers gem mangling https:// URLs.
# This block only lets secure_headers manage the other minor security headers.
SecureHeaders::Configuration.default do |config|
  config.x_frame_options = SecureHeaders::OPT_OUT
  config.csp = SecureHeaders::OPT_OUT
end